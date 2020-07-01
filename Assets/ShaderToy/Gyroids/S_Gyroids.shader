﻿Shader "Gyroids/S_Gyroids"
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
			#define MAX_DIST 100.0
			#define SURF_DIST 0.001
			
			float2 _MousePos;
			
			float2x2 Rot(float a)
			{
				float s = sin(a);
				float c = cos(a);
				return float2x2(c, -s, s, c);
			}
			
			float SDBox(float3 p, float3 s)
			{
				p = abs(p) - s;
				//length(max(p, 0.0)) 外部距离
				//min(max(p.x), max(p.y, p.z)), 0.0) 如果在内部 是负数
				return length(max(p, 0.0)) + min(max(p.x, max(p.y, p.z)), 0.0);
			}
			
			float SDGyroid(float3 p, float scale, float thickness, float bias)
			{
				p *= scale;
				float gyroid = abs((dot(sin(p * 2.0), cos(p.zxy * 1.23)) - bias) / (2.0 * scale)) - thickness;
				return gyroid;
			}
			
			float GetDist(float3 p)
			{
				float box = SDBox(p - float3(0, 1, 0), float3(1, 1, 1));
				
				float gyroid = SDGyroid(p, 8.0, 0.05, 1.);
				
				float d = max(box, gyroid * 0.8);
				
				return d;
			}
			
			float RayMarch(float3 ro, float3 rd)
			{
				float d0 = 0;
				
				for (int i = 0; i < MAX_STEPS; ++ i)
				{
					float3 p = ro + rd * d0;
					float dS = GetDist(p);
					d0 += dS;
					if (d0 > MAX_DIST || abs(dS) < SURF_DIST)
					{
						break;
					}
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
			
			float3 GetRayDir(float2 uv, float3 p, float3 l, float z)
			{
				float3 f = normalize(l - p);
				float3 r = normalize(cross(float3(0, 1, 0), f));
				float3 u = cross(f, r);
				float3 c = p + f * z;
				float3 i = c + uv.x * r + uv.y * u;
				float3 d = normalize(i - p);
				return d;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos.xy;
				
				float3 col = float3(0, 0, 0);
				
				float3 ro = float3(0, 3, -3);
				ro.yz = mul(Rot(-m.y * 3.14 + 1.0), ro.yz);
				ro.xz = mul(Rot(-m.x * 6.2831), ro.xz);
				
				float3 rd = GetRayDir(uv, ro, float3(0, 1, 0), 1.0);
				
				float d = RayMarch(ro, rd);
				
				if(d < MAX_DIST)
				{
					float3 p = ro + rd * d;
					float3 n = GetNormal(p);
					
					float dif = dot(n, normalize(float3(1, 2, 3))) * 0.5 + 0.5;
					col += dif;
				}
				
				//col *= 0.0;
				//d = SDGyroid(float3(uv.xy, _Time.y * 0.1), 20.0, 0.01, 0.0).xxx;
				//col += abs(d) * 10.0;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
