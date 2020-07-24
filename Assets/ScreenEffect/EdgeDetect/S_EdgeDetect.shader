Shader "ScreenEffect/S_EdgeDetect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		[Header (Detect)]
		_SampleDistance0("Sample Distance", Range(0, 2)) = 1
		_EdgePower ("edgePower", Range(0, 5)) = 1
		
		[Header (Pre)]
		_SampleDistance1("Sample Distance1", Range(0, 2)) = 0.17
		
		[Header (Final)]
		_UpThrehold("Up Threhold", Range(0, 5)) = 0
		_LowThrehold ("Low Threhold", Range(0, 5)) = 0
		_CompareLength ("Compare Length", Range(0, 5)) = 0
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		
		//detect
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
				half2 uv[9]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			half2 _MainTex_TexelSize;
			float  _EdgePower, _SampleDistance0;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv + _MainTex_TexelSize * half2(-1, 1) * _SampleDistance0;
				o.uv[1] = v.uv + _MainTex_TexelSize * half2(0, 1) * _SampleDistance0;
				o.uv[2] = v.uv + _MainTex_TexelSize * half2(1, 1) * _SampleDistance0;
				o.uv[3] = v.uv + _MainTex_TexelSize * half2(-1, 0) * _SampleDistance0;
				o.uv[4] = v.uv + _MainTex_TexelSize * half2(0, 0) * _SampleDistance0;
				o.uv[5] = v.uv + _MainTex_TexelSize * half2(1, 0) * _SampleDistance0;
				o.uv[6] = v.uv + _MainTex_TexelSize * half2(-1, -1) * _SampleDistance0;
				o.uv[7] = v.uv + _MainTex_TexelSize * half2(0, -1) * _SampleDistance0;
				o.uv[8] = v.uv + _MainTex_TexelSize * half2(1, -1) * _SampleDistance0;
				return o;
			}
			
			half4 EdgeDetect(v2f input)
			{
				const half Gsx[9] = {
					- 1, -2, -1,
					0, 0, 0,
					1, 2, 1
				};
				
				const half Gsy[9] = {
					- 1, 0, 1,
					- 2, 0, 2,
					- 1, 0, 1
				};
				
				half gx = 0, gy = 0;
				for (int i = 0; i < 9; i ++)
				{
					half lumin = Luminance(tex2D(_MainTex, input.uv[i]).rgb);
					gx += Gsx[i] * lumin;
					gy += Gsy[i] * lumin;
				}
				
				return 1 - (abs(gx) + abs(gy));//越接近边缘返回值越小
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float4 col = tex2D(_MainTex, i.uv[4]);
				half evalue = EdgeDetect(i);
				evalue = pow(evalue, _EdgePower);
				
				return float4(evalue, evalue, evalue, 1);
			}
			
			ENDCG
			
		}
		
		//pre
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
				half2 uv[9]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			float4 _Scale;
			sampler2D _MainTex;
			half2 _MainTex_TexelSize;
			float _SampleDistance1;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv + _MainTex_TexelSize * half2(-1, 1) * _SampleDistance1;
				o.uv[1] = v.uv + _MainTex_TexelSize * half2(0, 1) * _SampleDistance1;
				o.uv[2] = v.uv + _MainTex_TexelSize * half2(1, 1) * _SampleDistance1;
				o.uv[3] = v.uv + _MainTex_TexelSize * half2(-1, 0) * _SampleDistance1;
				o.uv[4] = v.uv + _MainTex_TexelSize * half2(0, 0) * _SampleDistance1;
				o.uv[5] = v.uv + _MainTex_TexelSize * half2(1, 0) * _SampleDistance1;
				o.uv[6] = v.uv + _MainTex_TexelSize * half2(-1, -1) * _SampleDistance1;
				o.uv[7] = v.uv + _MainTex_TexelSize * half2(0, -1) * _SampleDistance1;
				o.uv[8] = v.uv + _MainTex_TexelSize * half2(1, -1) * _SampleDistance1;
				return o;
			}
			
			half4 EdgeDetect(v2f input)
			{
				const half Gsx[9] = {
					- 1, -2, -1,
					0, 0, 0,
					1, 2, 1
				};
				
				const half Gsy[9] = {
					- 1, 0, 1,
					- 2, 0, 2,
					- 1, 0, 1
				};
				
				float2 gradientDirection = 0;
				
				for (int i = 0; i < 9; i ++)
				{
					half lumin = Luminance(tex2D(_MainTex, input.uv[i]).rgb);
					gradientDirection.x += Gsx[i] * lumin;
					gradientDirection.y += Gsy[i] * lumin;
				}
				
				float gradientMagnitude = gradientDirection * gradientDirection;
				float2 normalizedDirection = normalize(gradientDirection);
				normalizedDirection = sign(normalizedDirection) * floor(abs(normalizedDirection) + 0.617316); // Offset by 1-sin(pi/8) to set to 0 if near axis, 1 if away
				normalizedDirection = (normalizedDirection + 1.0) * 0.5; //-1~1 映射为 0~1
				return half4(gradientMagnitude, normalizedDirection, 1);
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float4 col = tex2D(_MainTex, i.uv[4]);
				half4 currentGradientAndDirection = EdgeDetect(i);
				return currentGradientAndDirection;
			}
			
			
			ENDCG
			
		}
		
		
		
		//final
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
				half2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			half2 _MainTex_TexelSize;
			float _UpThrehold, _LowThrehold, _CompareLength;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv ;
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float4 col = tex2D(_MainTex, i.uv);
				
				
				float3 currentGradientAndDirection = tex2D(_MainTex, i.uv).rgb;
				float2 gradientDirection = ((currentGradientAndDirection.gb * 2.0) - 1.0) * _MainTex_TexelSize.xy * _CompareLength;
				
				float SampledGradientMagnitude1 = tex2D(_MainTex, i.uv + gradientDirection).r;
				float SampledGradientMagnitude2 = tex2D(_MainTex, i.uv - gradientDirection).r;
				
				// 非极大值抑制
				float multiplier = step(SampledGradientMagnitude1, currentGradientAndDirection.r);
				multiplier = multiplier * step(SampledGradientMagnitude2, currentGradientAndDirection.r);
				
				
				//用双阈值算法检测
				float thresholdCompliance = smoothstep(_LowThrehold, _UpThrehold, currentGradientAndDirection.r);
				multiplier = multiplier * thresholdCompliance;
				
				return float4(multiplier, multiplier, multiplier, 1.0);
			}
			
			ENDCG
			
		}
	}
}
