Shader "Other/S_RayMarchingTricks"
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
			#define MAX_DIST 100.
			#define SURF_DIST 0.01
			
			float2 _MousePos;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float2x2 Rot(float a)
			{
				float s = sin(a);
				float c = cos(a);
				return float2x2(c, -s, s, c);
			}
			
			float SMin(float a, float b, float k)
			{
				float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
				return lerp(b, a, h) - k * h * (1.0 - h);
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
			
			float SDCylinder(float3 p, float3 a, float3 b, float r)
			{
				float3 ab = b - a;
				float3 ap = p - a;
				
				float t = dot(ab, ap) / dot(ab, ab);
				t = clamp(t, 0.0, 1.0);//去掉头尾限制
				
				float3 c = a + t * ab;
				
				float x = length(p - c) - r;
				float y = (abs(t - 0.5) - 0.5) * length(ab);
				float e = length(max(float2(x, y), 0.0));
				float i = min(max(x, y), 0);//用于阴影 bias
				
				return e + i;
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
			
			float SDBox(float3 p, float3 c, float3 size)
			{
				p = abs(p - c) - size;
				return length(max(p, 0.0)) + min(max(p.x, max(p.y, p.z)), 0.0);
			}
			
			float GetDist(float3 p)
			{
				float plane = dot(p, normalize(float3(0, 1, 0)));
				
				float box = SDBox(p, float3(0, 1, 0), float3(1, 1, 0.1));
				//box -= sin(p.x * 7.5 + _Time.y * 3.0) * 0.05;
				//box = abs(box) - 0.1;//镂空
				
				float d = min(plane * 0.6, box);
				
				return d ;
			}
			
			float RayMarch(float3 ro, float3 rd)
			{
				float d0 = 0;
				
				for (int i = 0; i < MAX_STEPS; ++ i)
				{
					float3 p = ro + rd * d0;
					float ds = GetDist(p);
					d0 += ds;
					if (d0 > MAX_DIST || abs(ds) < SURF_DIST)
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
				float3 lightPos = float3(3, 5, 4);
				float3 l = normalize(lightPos - p);
				float3 n = GetNormal(p);
				
				float dif = clamp(dot(n, l) * 0.5 + 0.5, 0.0, 1.0);
				float d = RayMarch(p + n * SURF_DIST * 2.0, l);
				
				/*
				if(p.y<0.01 && d < length(lightPos - p))
				{
					//plane的阴影用
					dif *= 0.5;
				}
				*/
				
				return dif;
			}
			
			float3 R(float2 uv, float3 p, float3 l, float z)
			{
				float3 f = normalize(l - p);
				float3 r = normalize(cross(float3(0, 1, 0), f));
				float3 u = cross(f, r);
				float3 c = p + f * z;
				float3 i = c + uv.x * r + uv.y * u;
				float3 d = normalize(i - p);
				return d;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				float2 m = _MousePos;
				
				float3 col = float3(0.0, 0.0, 0.0);
				float3 ro = float3(0, 4, -5);
				
				ro.yz = mul(Rot(-m.y * 3.14 + 1.0), ro.yz);
				ro.xz = mul(Rot(-m.x * 6.2831), ro.xz);
				
				
				float3 rd = R(uv, ro, float3(0, 1, 0), 1.0);
				float d = RayMarch(ro, rd);
				
				if (d < MAX_DIST)
				{
					
					float3 p = ro + rd * d;
					
					float dif = GetLight(p);
					col = float3(dif, dif, dif);
				}
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
