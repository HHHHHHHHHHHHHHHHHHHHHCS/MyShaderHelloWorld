Shader "My/S_RayMarchingSimpleShapes"
{
	Properties { }
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
			
			#define MAX_STEPS 100
			#define MAX_DIST 100
			#define SURF_DIST 0.01
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float SDCapsule(float3 p, float3 a, float3 b, float r)
			{
				float3 ab = b - a;
				float3 ap = p - a;
				
				float t = dot(ab, ap) / dot(ab, ab);
				t = clamp(t, 0.0, 1.0);
				
				float3 c = a + t * ab;
				return length(p - c) - r;
			}
			
			float SDSphere(float3 p, float3 s, float r)
			{
				float sphereDist = length(p - s.xyz) - r;
				return sphereDist;
			}
			
			float SDTorus(float3 p, float3 s, float2 r)
			{
				float3 o = p - s;
				float x = length(o.xz) - r.x;
				return length(float2(x, o.y)) - r.y;
			}
			
			float SDPlane(float3 p, float3 c)
			{
				float height = p.y - c.y;
				return height;
			}
			
			float GetDist(float3 p)
			{
				float sphereDist = SDSphere(p, float3(0, 1, 6), 1);
				float planeDist = SDPlane(p, float3(0, 0, 0));
				float capsuleDist = SDCapsule(p, float3(0, 1, 6), float3(1, 2, 6), 0.2);
				float torusDist = SDTorus(p, float3(-0.5, 0.5, 6), float2(1.5, 0.5));
				
				float d = min(torusDist, planeDist);
				return d;
			}
			
			float RayMarch(float3 ro, float3 rd)
			{
				float d0 = 0;
				
				for (int i = 0; i < MAX_STEPS; ++ i)
				{
					float3 p = ro + rd * d0;
					float ds = GetDist(p);
					d0 += ds;
					if (d0 > MAX_DIST || ds < SURF_DIST)
						break;
				}
				
				return d0;
			}
			
			float3 GetNormal(float3 p)
			{
				float d = GetDist(p);
				float2 e = float2(0.001, 0);
				
				float3 n = d - float3(
					GetDist(p - e.xyy),
					GetDist(p - e.yxy),
					GetDist(p - e.yyx)
				);
				
				return normalize(n);
			}
			
			float GetLight(float3 p)
			{
				float3 lightPos = float3(0, 5, 6);
				lightPos.xz += 2 * float2(sin(_Time.y), cos(_Time.y));
				float3 l = normalize(lightPos - p);
				float3 n = GetNormal(p);
				
				float dif = clamp(dot(n, l), 0.0, 1.0);
				float d = RayMarch(p + n * SURF_DIST * 2.0, l);
				if(d < length(lightPos - p))
				{
					//plane的阴影用
					dif *= 0.1;
				}
				
				return dif;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				
				float3 col = float3(0.0, 0.0, 0.0);
				float3 ro = float3(0, 2, 0);
				//视野偏移用
				float3 rd = normalize(float3(uv.x - 0.15, uv.y - 0.20, 1.0));
				
				float d = RayMarch(ro, rd);
				
				float3 p = ro + rd * d;
				
				float dif = GetLight(p);
				col = float3(dif, dif, dif);
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
