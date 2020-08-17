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
			
			float3 Streetlights(Ray r, float t)
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
			
			float N(float t)
			{
				return frac(sin(t * 3456.0) * 6547.0);
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
				
				float3 col = float3(0, 0, 0);
				
				float2 m = _MousePos;
				float3 camPos = float3(0.5, 0.2, 0);
				float3 lookat = float3(0.5, 0.2, 1.0);
				
				Ray r = GetRay(uv, camPos, lookat, 2.0);
				
				float t = _Time.y * 0.1 + m.x;
				
				col = Streetlights(r, t);
				col += HeadLights(r, t);
				col += TailLights(r, t);
				
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
