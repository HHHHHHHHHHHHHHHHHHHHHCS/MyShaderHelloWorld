Shader "ShaderToy/S_NewYear"
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
			
			//Firework
			//-------------------
			
			#define NUM_EXPLOSIONS 5.0
			#define NUM_PARTICLES 100.0
			
			float2 Hash12(float t)
			{
				float x = frac(sin(t * 674.3) * 453.2);
				float y = frac(sin((t + x) * 714.3) * 263.2);
				return float2(x, y);
			}
			
			float2 Hash12_Polar(float t)
			{
				float a = frac(sin(t * 674.3) * 453.2) * UNITY_TWO_PI;
				float d = frac(sin((t + a) * 714.3) * 263.2);
				return float2(sin(a), cos(a)) * d;
			}
			
			float Explosion(float2 uv, float t)
			{
				float sparks = 0.0;
				for (float i = 0.0; i < NUM_PARTICLES; ++ i)
				{
					float2 dir = Hash12_Polar(i + 1.0) * 0.5;
					float d = length(uv - dir * t);
					
					float brightness = lerp(0.0005, 0.002, smoothstep(0.05, 0.0, t));
					
					brightness *= sin(t * 20.0 + i) * 0.5 + 0.5;
					brightness *= smoothstep(1.0, 0.75, t);
					sparks += brightness / d;
				}
				return sparks;
			}
			
			
			//Number
			//---------------------------------
			
			#define QUALITY 1
			#define LOOP_COUNT 2
			
			float Hash1(float n)
			{
				return frac(sin(n) * 43758.5453123);
			}
			
			//伪随机半球点
			float3 ForwardSF(float i, float n)
			{
				float phi = UNITY_TWO_PI * frac(i / UNITY_HALF_PI);
				float zi = 1.0 - (2.0 * i + 1.0) / n;
				float sinTheta = sqrt(1.0 - zi * zi);
				return float3(cos(phi) * sinTheta, sin(phi) * sinTheta, zi);
			}
			
			//让曲线更加平滑
			//(http://www.iquilezles.org/www/articles/functions/functions.htm)
			float AlmostIdentity(float x, float m, float n)
			{
				if (x > m)
				{
					return x;
				}
				float a = 2.0 * n - m;
				float b = 2.0 * m - 3.0 * n;
				float t = x / m;
				return(a * t + b) * t * t + n;
			}
			
			float SDBox(float3 p, float3 c, float3 size)
			{
				return length(max(abs(p - c) - size, 0));
			}
			
			float2 Map(float3 q)
			{
				
				//放大增加准确度
				q *= 100.0;
				
				//x是距离  y是是否碰到 2.0没有碰到  1.0碰到了
				float2 res = float2(q.y, 2.0);
				
				float d = SDBox(q, float3(-20.0, +25.0, 0.0), float3(6.0, 2.0, 3.0));
				d = min(d, SDBox(q, float3(-16.0, +21.0, 0.0), float3(2.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(-20.0, +17.0, 0.0), float3(6.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(-24.0, +13.0, 0.0), float3(2.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(-20.0, +9.0, 0.0), float3(6.0, 2.0, 3.0)));
				
				d = min(d, SDBox(q, float3(-5.0, +25.0, 0.0), float3(6.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(-9.0, +17.0, 0.0), float3(2.0, 6.0, 3.0)));
				d = min(d, SDBox(q, float3(-1.0, +17.0, 0.0), float3(2.0, 6.0, 3.0)));
				d = min(d, SDBox(q, float3(-5.0, +9, 0.0), float3(6.0, 2.0, 3.0)));
				
				d = min(d, SDBox(q, float3(+10.0, +25.0, 0.0), float3(6.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(+14.0, +21.0, 0.0), float3(2.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(+10.0, +17.0, 0.0), float3(6.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(+6.0, +13.0, 0.0), float3(2.0, 2.0, 3.0)));
				d = min(d, SDBox(q, float3(+10.0, +9.0, 0.0), float3(6.0, 2.0, 3.0)));
				
				d = min(d, SDBox(q, float3(+23.0, 17.0, 0.0), float3(2.0, 10.0, 3.0)));
				
				if (d < res.x)
				{
					res = float2(d, 1.0);
				}
				
				res.x /= 100.0;
				return res;
			}
			
			float2 Intersect(in float3 ro, in float3 rd)
			{
				const float maxd = 1.0;
				
				float2 res = float2(0.0, 0.0);
				float t = 0.2;
				
				for (int i = 0; i < 300; ++ i)
				{
					float2 h = Map(ro + rd * t);
					if ((h.x < 0.0) || (t > maxd))
					{
						break;
					}
					t += h.x;
					res = float2(t, h.y);
				}
				if (t > maxd)
				{
					res = float2(-1.0, -1.0);
				}
				return res;
			}
			
			float3 CalcNormal(in float3 pos)
			{
				float3 eps = float3(0.005, 0.0, 0.0);
				return normalize(float3(
					Map(pos + eps.xyy).x - Map(pos - eps.xyy).x,
					Map(pos + eps.yxy).x - Map(pos - eps.yxy).x,
					Map(pos + eps.yyx).x - Map(pos - eps.yyx).x
				));
			}
			
			float CalcAO(in float3 pos, in float3 nor)
			{
				float ao = 0.0;
				for (int i = 0; i < 64; ++ i)
				{
					float3 kk;
					float3 ap = ForwardSF(float(i), 64.0);
					ap *= sign(dot(ap, nor)) * Hash1(float(i));
					//随机采样周围球的点   然后如果周围有点 则是阴影
					ao += clamp(Map(pos + nor * 0.01 + ap * 0.2).x * 20.0, 0.0, 1.0);
				}
				ao /= 64.0;
				
				return clamp(ao, 0.0, 1.0);
			}
			
			half3 Render(float2 p)
			{
				//Camera
				//-----------------------
				float an = 0;//0.1 * _Time.y;
				
				//摄像机点
				float3 ro = float3(0.4 * sin(an), 0.25, 0.4 * cos(an));
				//目标点
				float3 ta = float3(0.0, 0.15, 0.0);
				//camera matrix
				float3 ww = normalize(ta - ro);
				float3 uu = normalize(cross(ww, float3(0.0, 1.0, 0.0)));
				float3 vv = normalize(cross(uu, ww));
				//create view ray
				//有点椎体射线的感觉
				float3 rd = normalize(p.x * uu + p.y * vv + 1.7 * ww);
				
				//Render
				//----------------------
				float3 col = float3(1.0, 0.9, 0.7);
				
				//Raymarch
				float3 uvw;
				float2 res = Intersect(ro, rd);
				float t = res.x;
				
				if (t > 0.0)
				{
					float3 pos = ro + t * rd;
					float3 nor = CalcNormal(pos);
					float3 ref = reflect(rd, nor);
					float fre = clamp(1.0 + dot(nor, rd), 0.0, 1.0);
					
					float occ = CalcAO(pos, nor);
					occ = occ * occ;
					
					//heart
					if (res.y < 1.5)
					{
						col = float3(0.9, 0.02, 0.01);
						col = col * 0.72 + 0.2 * fre * float3(1.0, 0.8, 0.2);
						
						float3 lin = 4.0 * float3(0.7, 0.8, 1.0) * (0.5 + 0.5 * nor.y) * occ;
						lin += 0.8 * fre * float3(1.0, 1.0, 1.0) * (0.6 + 0.4 * occ);
						col = col * lin;
						col += 4.0 * float3(0.8, 0.9, 1.0) * smoothstep(0.0, 0.4, ref.y) * (0.06 + 0.94 * pow(fre, 5.0)) * occ;
						
						col = pow(col, 0.4545);
					}
					else
					{
						//ground
						col *= clamp(sqrt(occ * 1.8), 0.0, 1.0);
					}
				}
				
				
				col = clamp(col, 0.0, 1.0);
				
				return col;
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
				float2 uv = i.uv * 2 - 1;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				
				//Firework
				half3 col0 = 0;
				for (float z = 0.0; z < NUM_EXPLOSIONS; ++ z)
				{
					float t = _Time.y + z / NUM_EXPLOSIONS;
					float ft = floor(t);
					half3 color = sin(half3(0.34, 0.54, 0.43) * ft + float3(1.1244, 3.43215, 6.435)) * 0.5 + 0.5;
					float2 offs = Hash12(z + 1.0 + ft) - 0.5;
					offs *= float2(1.77, 1.0);
					//col += 0.0004 / length(uv - offs);
					col0 += Explosion(uv - offs, frac(t)) * color;
				}
				col0 *= 2.0;
				
				//Number
				half3 col1 = 0;
				#if QUALITY > 1
					for (int m = 0; m < LOOP_COUNT; ++ m)
					{
						for (int n = 0; n < LOOP_COUNT; ++ n)
						{
							//0~1 像素 * 2 = 0~2个像素
							float2 px = 2 * float2(m, n) / LOOP_COUNT / _ScreenParams.y;
							
							col1 += Render(uv + px);
						}
					}
					col1 /= float(LOOP_COUNT * LOOP_COUNT);
				#else
					col1 = Render(uv);
				#endif
				
				//暗边
				col1 *= 0.2 + 0.8 * pow(16.0 * i.uv.x * i.uv.y * (1.0 - i.uv.x) * (1.0 - i.uv.y), 0.2);
				
				return half4(pow(col0 + col1, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
