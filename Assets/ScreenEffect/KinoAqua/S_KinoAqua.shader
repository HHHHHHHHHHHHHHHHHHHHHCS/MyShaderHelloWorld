Shader "ScreenEffect/S_KinoAqua"
{
	Properties
	{
		//不能注释  因为blit要传入
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _Noise;

			float4 _EffectParams1;
			float2 _EffectParams2;
			float4 _EdgeColor;
			float4 _FillColor;
			uint _Iteration;

			#define OPACITY         _EffectParams1.x
			#define INTERVAL        _EffectParams1.y
			#define BLUR_WIDTH      _EffectParams1.z
			#define BLUR_FREQ       _EffectParams1.w
			#define EDGE_CONTRAST   _EffectParams2.x
			#define HUE_SHIFT       _EffectParams2.y

			// Vertically normalized screen coordinates to UV
			float2 UV2SC(float2 uv)
			{
				float2 p = uv - 0.5;
				p.x *= _ScreenParams.x / _ScreenParams.y;
				return p;
			}

			v2f vert(a2v IN)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(IN.vertex);
				o.uv = IN.uv;
				return o;
			}

			half4 frag(v2f IN) : SV_Target
			{
				float2 p = UV2SC(IN.uv);

				float2 p_e_n = p;
				float2 p_e_p = p;
				float2 p_c_n = p;
				float2 p_c_p = p;

				const float Stride = 0.04 / _Iteration;

				float acc_e = 0;
				float3 acc_c = 0;
				float sum_e = 1e-6;//避免0
				float sum_c = 1e-6;//避免0

				for (uint i = 0; i < _Iteration; i++)
				{
					// float w_e = 1.5 - (float)i / _Iteration;
					// acc_e += ProcessEdge(p_e_n, -Stride) * w_e;
					// acc_e += ProcessEdge(p_e_n, +Stride) * w_e;
					// sum_e += w_e * 2;
					//
					// float w_c = 0.2 + (float)i / _Iteration;
					// acc_c += ProcessFill(p_c_n, -Stride * BLUR_WIDTH) * w_c;
					// acc_c += ProcessFill(p_c_n, +Stride * BLUR_WIDTH) * w_c * 0.3;
					// sum_c += w_c * 1.3;
				}

				//normalize and contrast
				acc_e /= sum_e;
				acc_c /= sum_c;

				acc_e = saturate((acc_e - 0.5) * EDGE_CONTRAST + 0.5);;

				//color blending

				float3 rgb_e = lerp(1, _EdgeColor.rgb, _EdgeColor.a * acc_e);
				float3 rgb_f = lerp(1, acc_c, _FillColor.a) * _FillColor.rgb;

				half4 src = tex2D(_MainTex, IN.uv);

				return half4(lerp(src.rgb, rgb_e * rgb_f,OPACITY), src.a);
			}
			ENDCG
		}
	}
}