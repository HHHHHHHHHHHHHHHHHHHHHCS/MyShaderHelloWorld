Shader "ShaderToy/S_Gyroids"
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
				float gyroid = abs(dot(sin(p), cos(p.zxy)) - bias) / scale - thickness;
				return gyroid;
			}
			
			float3 Transform(float3 p)
			{
				p.xy = mul(Rot(p.z * 0.15), p.xy);
				p.z -= _Time.y * 0.1;
				p.y -= 0.3;
				return p;
			}
			
			float GetDist(float3 p)
			{
				p = Transform(p);
				float box = SDBox(p, float3(1, 1, 1));
				
				float g1 = SDGyroid(p, 5.23, 0.03, 1.4);
				float g2 = SDGyroid(p, 10.76, 0.03, 0.3);
				float g3 = SDGyroid(p, 20.76, 0.03, 0.3);
				float g4 = SDGyroid(p, 35.76, 0.03, 0.3);
				float g5 = SDGyroid(p, 60.76, 0.03, 0.3);
				float g6 = SDGyroid(p, 110.76, 0.03, 0.3);
				
				
				//float g = min(g1, g2); // union
				//float g = max(g1, -g2); // subtraction
				float g = 0;
				g += g1;
				g += -g2 * 0.4;
				g += -g3 * 0.3;
				g += g4 * 0.2;
				g += g5 * 0.2;
				g += g6 * 0.3;
				
				float d = g * 0.8;//max(box, g * 0.8);//g * 0.8;
				
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
				float2 e = float2(0.01, 0);
				
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
			
			float3 Background(float3 rd)
			{
				float3 col = float3(0.0, 0.0, 0.0);
				float t = _Time.y;
				
				float y = rd.y * 0.5 + 0.5;
				
				col += (1.0 - y) * float3(1.0, 0.4, 0.1) * 2.0;
				
				float a = atan2(rd.x, rd.z);
				float flames = sin(a * 10.0 + t) * sin(a * 7.0 - t) * sin(a * 6.0);
				flames *= smoothstep(0.8, 0.5, y);
				col += flames;
				col = max(col, 0.0);
				col += (0.5, 0.0, y);
				
				return col;
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
				float t = _Time.y;
				
				float3 col = float3(0, 0, 0);
				
				uv += sin(uv * 20.0 + t) * 0.01;
				
				float3 ro = float3(0, 0, -0.03) ;
				ro.yz = mul(Rot(-m.y * 3.14 + 1.0), ro.yz);
				ro.xz = mul(Rot(-m.x * 6.2831), ro.xz);
				
				float3 lookat = float3(0, 0, 0);
				float3 rd = GetRayDir(uv, ro, lookat, 0.8);
				
				float d = RayMarch(ro, rd);
				
				if(d < MAX_DIST)
				{
					float3 p = ro + rd * d;
					float3 n = GetNormal(p);
					
					float dif = n.y * 0.5 + 0.5;
					col += dif * dif;
					
					float height = p.y;
					p = Transform(p);
					float g2 = SDGyroid(p, 10.76, 0.03, 0.3);
					col *= smoothstep(-0.1, 0.1, g2);
					
					float crackWidth = -0.02 + smoothstep(0.0, -0.5, n.y) * 0.04;
					float cracks = smoothstep(crackWidth, -0.03, g2);
					float g3 = SDGyroid(p + t * 0.1, 5.76, 0.03, 0.0);
					float g4 = SDGyroid(p - t * 0.05, 4.76, 0.03, 0.0);
					
					cracks *= g3 * g4 * 20.0 + 0.2 * smoothstep(0.2, 0.0, n.y);
					
					col += cracks * float3(1.0, 0.4, 0.1) * 3.0;
					
					float g5 = SDGyroid(p - float3(0, t, 0), 3.76, 0.03, 0.0);
					col += g5 * float3(1, 0.4, 0.1);
					
					//col += smoothstep(0.0, -0.2, height) * float3(1.0, 0.4, 0.1);
				}
				
				col = lerp(col, Background(rd), smoothstep(0.0, 7.0, d)) ;
				
				//col = Background(rd);
				col *= 1.0 - dot(uv, uv);
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
