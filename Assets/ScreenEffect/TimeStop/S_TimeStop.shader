Shader "TimeStop/S_TimeStop"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_NoiseTex ("Noise Texture", 2D) = "white" { }
		[Toggle]_Gray ("Gray", float) = 0
		_CenterX ("Center X", float) = 0.0
		_CenterY ("Center Y", float) = 0.0
		_Radius ("Radius", float) = 0.2
		_ImpactRadius ("Impact Radius", float) = 0.4
		_ImpactRadius1 ("Impact Radius1", float) = 1.0
		_ImpactColor ("Impact Color", Color) = (1, 1, 1, 1)
		_TwistIntensity ("TwistIntensity", float) = 1
		_TwistSpeed ("TwistSpeed", float) = 1
		_WaveIntensity ("WaveIntensity", float) = 1
		_WaveShape ("WaveShape", float) = 1
		[Header(Blur)]_SampleDist ("Sample Dist", float) = 0
		_SampleStrength ("Sample Strength", float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float _Gray;
			float _CenterX, _CenterY;
			float _Radius;
			float _ImpactRadius;
			float _ImpactRadius1;
			float4 _ImpactColor;
			float _TwistIntensity;
			float _TwistSpeed;
			float _WaveIntensity;
			float _WaveShape;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float3 RGB2HSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
				float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			
			float3 HSV2RGB(float3 c)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
			}
			
			
			float4 frag(v2f i): SV_Target
			{
				float aspect = _ScreenParams.x / _ScreenParams.y;
				float x = (i.uv.x - 0.5f - _CenterX) * aspect;
				float y = (i.uv.y - 0.5f - _CenterY) ;
				float d = x * x + y * y;
				
				
				//圆太规则了 , 制造出凹凸坑洼的效果
				float sin_theta = saturate(y / max(sqrt(d), 1e-8));//d = r^2 同时避免NAN
				float half_theta = asin(sin_theta) * (step(0, x) - 0.5);//根据x进行凹凸
				
				
				float4 col = tex2D(_MainTex, i.uv);
				float3 finalColor = col;
				
				//随时间波动 多个正弦波叠加
				float deformFactor = (1 + 0.02 * sin(half_theta * 24) * lerp(0, 0.5, sin(UNITY_TWO_PI * _Time.y * 0.5))
				+ 0.25 * x * sin(1 + half_theta * 6.5) * lerp(0.25, 0.75, sin(UNITY_TWO_PI * _Time.y * 0.2))
				+ 0.1 * x * x * sin(2 + half_theta * 9.5) * lerp(0.25, 0.75, sin(UNITY_TWO_PI * _Time.y * 0.1))
				);
				_Radius *= deformFactor;
				_ImpactRadius *= deformFactor;
				_ImpactRadius1 *= deformFactor;
				
				
				//noise
				float4 noise = tex2D(_NoiseTex, i.uv + _Time.y * _TwistSpeed);
				float4 twistedColor = tex2D(_MainTex, i.uv + noise.xy * _TwistIntensity);
				float4 wave = tex2D(_NoiseTex, half_theta * noise.xy * _WaveShape) * _WaveIntensity;
				
				//hsv
				float3 hsvColor = RGB2HSV(twistedColor.rgb);
				//hsv 跟时间变化
				hsvColor.x += lerp(0, 0.2, sin(UNITY_TWO_PI * frac(_Time.y * 0.5)));
				hsvColor.x = frac(hsvColor.x);
				//反色
				float3 reversedColor = 1 - HSV2RGB(hsvColor.rgb) + wave;
				//灰度圈
				float rr = _Radius * _Radius;
				half isGray = step(0.5, _Gray);
				half insideCircle = step(d, rr);
				finalColor = lerp(col, reversedColor, insideCircle);
				fixed3 grayFactor = {
					0.299, 0.587, 0.114
				};
				
				fixed grayColor = dot(grayFactor, col);
				finalColor = lerp(finalColor, grayColor, isGray * (1 - insideCircle));
				
				//impact wave
				const float power = 5;
				
				float t = saturate(d / (_ImpactRadius * _ImpactRadius));
				fixed4 rim = lerp(0, _ImpactColor, pow(t, power));
				finalColor += rim * rim.a * step(d, _ImpactRadius * _ImpactRadius);
				
				t = saturate(d / (_ImpactRadius1 * _ImpactRadius1));
				rim = lerp(0, _ImpactColor, pow(t, power));
				finalColor += rim * rim.a * step(d, _ImpactRadius1 * _ImpactRadius1);
				
				
				return float4(finalColor, 1.0);
			}
			ENDCG
			
		}
		
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _SampleDist;
			float _SampleStrength;
			float  _CenterX;
			float  _CenterY;
			
			half4 frag(v2f i): SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				
				if (_SampleStrength * _SampleDist == 0)
				{
					return col;
				}
				
				half4 sum = col;
				float2 dir = 0.5 - i.uv + float2(_CenterX, _CenterY);
				float dist = length(dir);
				dir /= dist;//normalize
				float samples[10] = {
					- 0.08,
					- 0.05,
					- 0.03,
					- 0.02,
					- 0.01,
					0.01,
					0.02,
					0.03,
					0.05,
					0.08
				};
				for (int it = 0; it < 10; it ++)
				{
					sum += tex2D(_MainTex, i.uv + dir * samples[it] * _SampleDist);
				}
				sum /= 11;
				float t = saturate(dist * _SampleStrength);
				float4 blur = lerp(col, sum, t);
				return blur;
			}
			ENDCG
			
		}
	}
}
