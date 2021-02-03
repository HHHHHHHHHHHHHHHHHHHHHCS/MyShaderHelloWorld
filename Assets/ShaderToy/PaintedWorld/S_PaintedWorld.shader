//https://www.shadertoy.com/view/3stBD2
Shader "ShaderToy/S_PaintedWorld"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
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
			
			float Random(in float2 st)
			{
				return frac(sin(dot(st.xy, 2.0 * float2(12.9898, 78.233))) * 43758.5453123);
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				const float TILES = 50.0f;
				
				float2 texcoords = i.uv;
				
				float invAspectRatio = ((1.0f - texcoords.y) * _ScreenParams.y) / _ScreenParams.x;
				
				//divide screen and use tile
				float2 st = 0;
				st.x = floor(texcoords * TILES);
				st.y = floor(invAspectRatio * TILES);
				
				//Get noise  (-1,-1)~(2,2)
				float noise1 = Random(st);
				float noise2 = Random(st + float2(0, 2));
				float noise3 = Random(st + float2(-1, -1));
				float noise4 = Random(st + float2(2, 2));
				float noise5 = Random(st + float2(2, 0));
				float noise6 = Random(st + float2(2, -1));
				float noise7 = Random(st + float2(-1, 0));
				float noise8 = Random(st + float2(1, 0));
				float noise9 = Random(st + float2(1, 2));
				float noise10 = Random(st + float2(-1, 2));
				float noise11 = Random(st + float2(2, 1));
				float noise12 = Random(st + float2(0, 1));
				float noise13 = Random(st + float2(-1, 1));
				float noise14 = Random(st + float2(0, -1));
				float noise15 = Random(st + float2(1, 1));
				float noise16 = Random(st + float2(1, -1));
				
				// Stage 1:
				// Calculate noise center on noise12:
				float p12 = 0.f;
				p12 += (noise7 + noise9 + noise8 + noise10) / 16.0;
				p12 += (noise1 + noise2 + noise15 + noise13) / 8.0;
				p12 += noise12 / 4.0;
				
				// Stage 2:
				// Calculate noise centered on noise15
				float p15 = 0.f;
				p15 += (noise1 + noise4 + noise5 + noise2) / 16.0;
				p15 += (noise8 + noise9 + noise11 + noise12) / 8.0;
				p15 += noise15 / 4.0;
				
				// Stage 3:
				// Calculate noise centered on noise1
				float p1 = 0.f;
				p1 += (noise3 + noise16 + noise13 + noise15) / 16.0;
				p1 += (noise12 + noise14 + noise8 + noise7) / 8.0;
				p1 += noise1 / 4.0;
				
				// Stage 4:
				// Calculate noise centered on noise8
				float p8 = 0.f;
				p8 += (noise11 + noise14 + noise6 + noise12) / 16.0;
				p8 += (noise15 + noise16 + noise5 + noise1) / 8.0;
				p8 += noise8 / 4.0;
				
				// Stage 5:
				// Interpolation
				
				//look like frac()
				float interp_x = TILES * texcoords.x - st.x;
				float interp_y = TILES * invAspectRatio - st.y;
				
				float t_lower = lerp(p12, p15, interp_x);
				float t_upper = lerp(p1, p8, interp_x);
				float t = lerp(t_upper, t_lower, interp_y);
				
				t *= UNITY_TWO_PI;
				
				float2 offsets;
				offsets.x = sin(t);
				offsets.y = cos(t);
				
				float3 color = float3(0.0f, 0.0f, 0.0f);
				for (int i = -5; i <= 5; ++ i)
				{
					float2 tex = texcoords + i * offsets / _ScreenParams.xy ;
					color += tex2D(_MainTex, tex).rgb;
				}
				color /= 11.0f;
				
				return half4(color.rgb, 1.0);
			}
			ENDCG
			
		}
	}
}
