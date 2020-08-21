Shader "ShaderToy/S_RainScreen"
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
			float4 _MainTex_ST;
			float2 _MousePos;
			
			struct Ray
			{
				float3 o;
				float3 d;
			};
			
			float N(float t)
			{
				return frac(sin(t * 3456.0) * 6547.0);
			}
			
			float4 N14(float t)
			{
				return frac(sin(t * float4(123.0, 1024.0, 3456.0, 9564.0)) * float4(6547.0, 345.0, 8799.0, 1564.0));
			}
			
			Ray GetRay(float2 uv, float3 camPos, float3 lookat, float zoom)
			{
				Ray ray;
				ray.o = camPos;
				float3 f = normalize(lookat - camPos);
				float3 r = cross(float3(0, 1, 0), f);
				float3 u = cross(f, r);
				float3 c = ray.o + f * zoom;
				
				float3 i = c + uv.x * r + uv.y * u;
				
				ray.d = normalize(i - ray.o);
				
				return ray;
			}
			
			float3 ClosetPoint(Ray r, float3 p)
			{
				return r.o + max(0.0, dot(p - r.o, r.d)) * r.d;
			}
			
			float3 DistRay(Ray r, float3 p)
			{
				return length(p - ClosetPoint(r, p));
			}
			
			float Bokeh(Ray r, float3 p, float size, float blur)
			{
				float d = DistRay(r, p);
				
				size *= length(p);
				float c = smoothstep(size, size * (1.0 - blur), d);
				
				c *= lerp(0.6, 1.0, smoothstep(size * 0.8, size, d));
				
				return c;
			}
			
			float3 StreetLights(Ray r, float t)
			{
				float side = step(r.d.x, 0.0);
				r.d.x = abs(r.d.x);
				
				float s = 1.0 / 10.0;
				float m = 0.0;
				
				for (float i = 0; i < 1.0; i += s)
				{
					float ti = frac(t + i + side * s * 0.5);
					float3 p = float3(2.0, 2.0, 100.0 - ti * 100.0);
					
					m += Bokeh(r, p, 0.05, 0.1) * ti * ti * ti;
				}
				
				return float3(1.0, 0.7, 0.3) * m;
			}
			
			float3 EnvLights(Ray r, float t)
			{
				float side = step(r.d.x, 0.0);
				r.d.x = abs(r.d.x);
				
				float s = 1.0 / 10.0;
				float3 c = 0.0;
				
				for (float i = 0; i < 1.0; i += s)
				{
					float ti = frac(t + i + side * s * 0.5);
					
					float4 n = N14(i + side * 100);
					
					float fade = ti * ti * ti;
					
					float occlusion = sin(ti * 6.28 * 10.0 * n.x) * 0.5 + 0.5;
					
					fade = occlusion;
					
					float x = lerp(2.5, 10.0, n.x);
					float y = lerp(0.1, 1.5, n.y);
					float3 p = float3(x, y, 50.0 - ti * 50.0);
					
					float3 col = n.wzy;
					c += Bokeh(r, p, 0.05, 0.1) * fade * col * 0.5;
				}
				
				return c;
			}
			
			
			float3 HeadLights(Ray r, float t)
			{
				t *= 2;
				
				float w1 = 0.25;
				float w2 = w1 * 1.2;
				
				float s = 1.0 / 30.0; //0.1
				float m = 0.0;
				
				for (float i = 0; i < 1.0; i += s)
				{
					float n = N(i);
					
					if (n > 0.1)
					{
						continue;
					}
					
					float ti = frac(t + i);
					float z = 100.0 - ti * 100.0;
					float fade = ti * ti * ti * ti * ti;
					float focus = smoothstep(0.9, 1.0, ti);
					
					float size = lerp(0.05, 0.03, focus);
					
					m += Bokeh(r, float3(-1.0 - w1, 0.15, z), size, 0.1) * fade;
					m += Bokeh(r, float3(-1.0 + w1, 0.15, z), size, 0.1) * fade;
					
					m += Bokeh(r, float3(-1.0 - w2, 0.15, z), size, 0.1) * fade;
					m += Bokeh(r, float3(-1.0 + w2, 0.15, z), size, 0.1) * fade;
					
					float ref = 0.0;
					ref += Bokeh(r, float3(-1.0 - w2, -0.15, z), size * 3.0, 1.0) * fade;
					ref += Bokeh(r, float3(-1.0 + w2, -0.15, z), size * 3.0, 1.0) * fade;
					
					m += ref * focus;
				}
				
				return float3(0.9, 0.9, 1.0) * m;
			}
			
			float3 TailLights(Ray r, float t)
			{
				t *= 0.25;
				
				float w1 = 0.25;
				float w2 = w1 * 1.2;
				
				float s = 1.0 / 15.0; //0.1
				float m = 0.0;
				
				for (float i = 0; i < 1.0; i += s)
				{
					float n = N(i); //[0,1]
					
					if (n > 0.5)
					{
						continue;
					}
					
					//n = [0,0.5]
					
					float lane = step(0.25, n);//0 or 1
					
					float ti = frac(t + i);
					float z = 100.0 - ti * 100.0;
					float fade = ti * ti * ti * ti * ti;
					float focus = smoothstep(0.9, 1.0, ti);
					
					float size = lerp(0.05, 0.03, focus);
					
					float laneShift = smoothstep(1.0, 0.96, ti);
					float x = 1.5 - lane * laneShift;
					
					float blink = step(0, sin(t * 1000.0)) * 7.0 * lane * step(0.96, ti);
					
					m += Bokeh(r, float3(x - w1, 0.15, z), size, 0.1) * fade;
					m += Bokeh(r, float3(x + w1, 0.15, z), size, 0.1) * fade;
					
					m += Bokeh(r, float3(x - w2, 0.15, z), size, 0.1) * fade;
					m += Bokeh(r, float3(x + w2, 0.15, z), size, 0.1) * fade * (1.0 + blink * 0.1);
					
					float ref = 0.0;
					ref += Bokeh(r, float3(x - w2, -0.15, z), size * 3.0, 1.0) * fade;
					ref += Bokeh(r, float3(x + w2, -0.15, z), size * 3.0, 1.0) * fade * (1.0 + blink * 0.1);
					
					m += ref * focus;
				}
				
				return float3(1.0, 0.1, 0.03) * m;
			}
			
			float2 Rain(float2 uv, float t)
			{
				t *= 40.0;
				//uv *= 3;
				
				float2 a = float2(3.0, 1.0);
				float2 st = uv * a ;
				
				float2 id = floor(st);
				st.y += t * 0.22;
				
				float n = frac(sin(id.x * 716.34) * 768.34);
				st.y += n;
				uv.y += n;
				
				id = floor(st);
				st = frac(st) - 0.5;
				
				t += frac(sin(id.x * 716.34 + id.y * 1453.7) * 768.34) * 6.283;
				float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.43;
				float2 p1 = float2(0, y);
				float2 o1 = (st - p1) / a;
				//除以a 可以变成从椭圆 变回 圆
				float d = length(o1);
				float m1 = smoothstep(0.07, 0.0, d);
				
				float2 o2 = (frac(uv * a.x * float2(1.0, 2.0)) - .5) / float2(1.0, 2.0);
				d = length(o2);
				float m2 = smoothstep(0.3 * (0.5 - st.y), 0.0, d) * smoothstep(-0.1, 0.1, st.y - p1.y);
				
				//因为x是缩放3倍的
				// if (st.x > 0.46 || st.y > 0.49)
				// 	m1 = 1;
				
				return  m1 * o1 * 30.0 + m2 * o2 * 30.0;
			}
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos;
				
				float3 col = float3(0, 0, 0);
				
				float t = _Time.y * 0.05 + m.x;
				
				float3 camPos = float3(0.5, 0.2, 0);
				float3 lookat = float3(0.5, 0.2, 1.0);
				
				float2 rainDistort = Rain(uv * 5.0, t) * 0.5;
				rainDistort += Rain(uv * 7.0, t) * 0.5;
				
				//轻微扭曲屏幕
				uv.x += sin(uv.y * 70.0) * 0.005;
				uv.y += sin(uv.x * 170.0) * 0.003;
				
				Ray r = GetRay(uv - rainDistort * 0.5, camPos, lookat, 2.0);
				
				
				col = StreetLights(r, t);
				col += HeadLights(r, t);
				col += TailLights(r, t);
				col += EnvLights(r, t);
				
				col += (r.d.y + 0.25) * float3(0.2, 0.1, 0.5);
				
				//col = float3(rainDistort, 0.0);
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
