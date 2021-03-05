Shader "Noise/S_VoronoiNoise"
{
	Properties
	{
		_AngleOffset ("Angle Offset", Float) = 1
		_CellDensity ("Cell Density", Float) = 1
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
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			float _AngleOffset;
			float _CellDensity;
			
			inline float2 GradientNoiseDir(float2 p)
			{
				p = p % 289;
				
				float x = float(34 * p.x + 1) * p.x % 289 + p.y;
				x = (34 * x + 1) * x % 289;
				x = frac(x / 41) * 2 - 1;
				return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
			}
			
			float GradientNoise(float2 uv, float scale)
			{
				float2 p = uv * scale;
				float2 ip = floor(p);
				float2 fp = frac(p);
				float d00 = dot(GradientNoiseDir(ip), fp);
				float d01 = dot(GradientNoiseDir(ip + float2(0, 1)), fp - float2(0, 1));
				float d10 = dot(GradientNoiseDir(ip + float2(1, 0)), fp - float2(1, 0));
				float d11 = dot(GradientNoiseDir(ip + float2(1, 1)), fp - float2(1, 1));
				fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
				return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
			}
			
			inline float2 VoronoiRandomVector(float2 uv, float offset)
			{
				float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
				uv = frac(sin(mul(uv, m)));
				return float2(sin(uv.y * offset) * 0.5 + 0.5, cos(uv.x * offset) * 0.5 + 0.5);
			}
			
			float2 Voronoi(float2 uv, float angleOffset, float cellDensity)
			{
				float2 g = floor(uv * cellDensity);
				float2 f = frac(uv * cellDensity);
				float t = 8.0;
				float3 res = float3(8.0, 0.0, 0.0);
				float2 ret = float2(0, 0);
				
				
				for (int y = -1; y <= 1; y ++)
				{
					for (int x = -1; x <= 1; x ++)
					{
						float2 lattice = float2(x, y);
						float2 offset = VoronoiRandomVector(lattice + g, angleOffset);
						float d = distance(lattice + offset, f);
						
						if (d < res.x)
						{
							res = float3(d, offset.x, offset.y);
							ret = res.xy;
						}
					}
				}
				
				return ret;
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half2 noise = Voronoi(i.uv, _AngleOffset, _CellDensity);
				return half4(noise.xy, 0, 1);
			}
			ENDCG
			
		}
	}
}
