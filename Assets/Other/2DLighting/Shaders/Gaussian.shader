Shader "Lighting2D/Gaussian"
{
	Properties
	{
		_MainTex ("LightTexture", 2D) = "white" { }
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Gaussian ("Gaussian", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "PreviewType" = "Plane" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
				float4 worldpos: TEXCOORD1;
				float4 shadowUV: TEXCOORD2;
			};
			
			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _Gaussian;
			float4 _Gaussian_TexelSize;
			int _BlurRadius;
			float2 _BlurDirection;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color * _Color;
				o.worldpos = mul(unity_ObjectToWorld, v.vertex);
				o.shadowUV = ComputeScreenPos(o.vertex);
				
				return o;
			}
			
			inline float GaussianWeight(int2 radius)
			{
				return tex2D(_Gaussian, radius.xy * _Gaussian_TexelSize.xy).r;
			}
			
			inline float3 Gaussian(float2 uv, int r, int R)
			{
				if (r == 0)
					return GaussianWeight(int2(r, R)) * tex2D(_MainTex, uv.xy);
				return GaussianWeight(int2(r, R)) * (
					tex2D(_MainTex, uv.xy + float2(r, r) * _BlurDirection * _MainTex_TexelSize.xy) +
					tex2D(_MainTex, uv.xy - float2(r, r) * _BlurDirection * _MainTex_TexelSize.xy));
					}
					
					float4 frag(v2f v): SV_TARGET
					{
						float3 color;
						for (int i = 0; i < _BlurRadius; i ++)
					{
						color += Gaussian(v.texcoord.xy, i, _BlurRadius - 1);
					}
					return float4(color, 1.0);
				}
				
				ENDCG
				
			}
		}
	}
