Shader "My/S_TimeStop"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_CenterX ("Center X", float) = 0.0
		_CenterY ("Center Y", float) = 0.0
		_Radius ("Radius", float) = 0.2
		_ImpactRadius ("Impact Radius", float) = 0.4
		_ImpactRadius1 ("Impact Radius1", float) = 1.0
		_ImpactColor ("Impact Color", Color) = (1, 1, 1, 1)
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
			float _CenterX, _CenterY;
			float _Radius;
			float _ImpactRadius;
			float _ImpactRadius1;
			float4 _ImpactColor;
			
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
				
				
				float4 col = tex2D(_MainTex, i.uv);
				float3 finalColor = col;
				
				
				//hsv
				float3 hsvColor = RGB2HSV(col.rgb);
				//hsv 跟时间变化
				hsvColor.x += lerp(0, 0.2, sin(UNITY_TWO_PI * frac(_Time.y * 0.5)));
				hsvColor.x = frac(hsvColor.x);
				
				//反色
				float3 reversedColor = 1 - HSV2RGB(hsvColor.rgb);
				
				//圆太规则了 , 制造出凹凸坑洼的效果
				float sin_theta = saturate(y / max(sqrt(d), 1e-8));//d = r^2 同时避免NAN
				float half_theta = asin(sin_theta) * (step(0, x) - 0.5);//根据x进行凹凸
				//随时间波动 多个正弦波叠加
				float deformFactor = (1 + 0.02 * sin(half_theta * 24) * lerp(0, 0.5, sin(UNITY_TWO_PI * _Time.y * 0.5))
				+ 0.25 * x * sin(1 + half_theta * 6.5) * lerp(0.25, 0.75, sin(UNITY_TWO_PI * _Time.y * 0.2))
				+ 0.1 * x * x * sin(2 + half_theta * 9.5) * lerp(0.25, 0.75, sin(UNITY_TWO_PI * _Time.y * 0.1))
				);
				_Radius *= deformFactor;
				
				if (d < _Radius * _Radius)
					finalColor = reversedColor;
				
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
	}
}
