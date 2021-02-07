Shader "ShaderToy/S_FoamyWater"
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
			
			#define TILING_FACTOR 1.0
			#define MAX_ITER 8
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float WaterHighlight(float2 p, float time, float foaminess)
			{
				float2 i = p;
				float c = 0.0;
				float foaminess_factor = lerp(1.0, 6.0, foaminess);
				float inten = 0.005 * foaminess_factor;
				
				for (int n = 0; n < MAX_ITER; ++ n)
				{
					float t = time * (1.0 - (3.5 / float(n + 1)));
					i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c += 1.0 / length(float2(p.x / (sin(i.x + t)), p.y / cos(i.y + t)));
				}
				
				c = 0.2 + c / (inten * MAX_ITER);
				c = 1.17 - pow(c, 1.4);
				c = pow(abs(c), 8.0);
				
				return c / sqrt(foaminess_factor);
			}
			
			half4 frag(v2f i): SV_Target
			{
				float time = _Time.y * 0.1 + 23.0;
				float2 uv = i.uv;
				float2 uv_square = float2(uv.x * _ScreenParams.x / _ScreenParams.y, uv.y);
				
				float dist_center = pow(2.0 * length(uv - 0.5), 2.0);
				
				float foaminess = smoothstep(0.4, 1.8, dist_center);
				float clearness = 0.1 + 0.9 * smoothstep(0.1, 0.5, dist_center);
				
				//[0,1.x] ->[0,1][0,x]
				float2 p = fmod(uv_square * UNITY_TWO_PI * TILING_FACTOR, UNITY_TWO_PI) - 250.0;
				
				float c = WaterHighlight(p, time, foaminess);
				
				float3 water_color = float3(0.0, 0.35, 0.5);
				float3 color = c;
				
				color = clamp(color + water_color, 0.0, 1.0);
				color = lerp(water_color, color, clearness);
				
				return half4(color, 1.0);
			}
			ENDCG
			
		}
	}
}
