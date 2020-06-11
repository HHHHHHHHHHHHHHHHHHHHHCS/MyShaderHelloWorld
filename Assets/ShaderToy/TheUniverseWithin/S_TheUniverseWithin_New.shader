Shader "TheUniverseWithin/S_TheUniverseWithin_New"
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
			
			#define NUM_LAYERS 4
			//#define SIMPLE
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float2 _MousePos;
			sampler2D _Noise;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float N21(float2 p)
			{
				float3 a = frac(float3(p.xyx) * float3(213.897, 653.453, 253.098));
				a += dot(a, a.yzx + 79.76);
				return frac((a.x + a.y) * a.z);
			}
			
			float2 GetPos(float2 id, float2 offs, float t)
			{
				float n = N21(id + offs);
				float n1 = frac(n * 10.0);
				float n2 = frac(n * 100.0);
				float a = t + n;
				return offs + float2(sin(a * n1), cos(a * n2)) * 0.4;
			}
			
			float GetT(float2 ro, float2 rd, float2 p)
			{
				return dot(p - ro, rd);
			}
			
			//垂直线长度/pa长度
			float LineDist(float3 a, float3 b, float3 p)
			{
				return length(cross(b - a, p - a)) / length(p - a);
			}
			
			//垂直的线长度
			float DF_Line(in float2 a, in float2 b, in float2 p)
			{
				float2 pa = p - a;
				float2 ba = b - a;
				float h = clamp(dot(pa, ba) / (1e-6 + dot(ba, ba)), 0.0, 1.0);
				return length(pa - ba * h);
			}
			
			float Line(float2 a, float2 b, float2 uv)
			{
				float r1 = 0.04;
				float r2 = 0.01;
				
				float d = DF_Line(a, b, uv);
				float d2 = length(a - b);
				
				//太短过渡
				float m = smoothstep(r1, r2, d);
				
				//距离太长 或者 太短都是渐变
				float fade = smoothstep(1.5, 0.5, d2);
				fade += smoothstep(0.05, 0.02, abs(d2 - 0.75));
				
				return m * fade;
			}
			
			float NetLayer(float2 st, float n, float t)
			{
				float2 id = floor(st) + n;
				
				st = frac(st) - 0.5;
				
				float2 p[9];
				int i = 0;
				for (float y = -1.0; y <= 1.0; y ++)
				{
					for (float x = -1.0; x < 1.0; x ++)
					{
						p[i ++ ] = GetPos(id, float2(x, y), t);
					}
				}
				
				float m = 0.0;
				float sparkle = 0.0;
				
				for (int i = 0; i < 9; i ++)
				{
					m += Line(p[4], p[i], st);
					
					float d = length(st - p[i]);
					
					float s = (0.005 / (d * d));
					s *= smoothstep(1.0, 0.7, d);
					//时亮时暗
					float pulse = sin((frac(p[i].x) + frac(p[i]).y + t) * 5.0) * 0.4 + 0.6;
					pulse = pow(pulse, 20.0);
					
					s *= pulse;
					sparkle += s;
				}
				
				//上下左右 的 格子 的线连接
				m += Line(p[1], p[3], st);
				m += Line(p[1], p[5], st);
				m += Line(p[7], p[5], st);
				m += Line(p[7], p[3], st);
				
				//sparkle * 周期
				float sPhase = (sin(t + n) + sin(t * .1)) * .25 + .5;
				sPhase += pow(sin(t * .1) * .5 + .5, 50.) * 5.;
				m += sparkle * sPhase;//(*.5+.5);
				
				return m;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float2 mouse = _MousePos - 0.5;
				
				float t = _Time.x;
				
				float s, c;
				sincos(t, s, c);
				float2x2 rot = float2x2(c, -s, s, c);
				float2 st = mul(rot, uv);
				mouse = mul(rot * 2.0, mouse);
				
				float m = 0;
				for (float i = 0.0; i < 1.0; i += 1.0 / NUM_LAYERS)
				{
					float z = frac(i + t);
					float size = lerp(15.0, 1.0, z);
					//过小 或者 过大 都会变淡
					float fade = smoothstep(0.0, 0.6, z)
					* smoothstep(1.0, 0.8, z);
					m += fade * NetLayer(st * size - mouse * z, i, _Time.y) ;
				}
				
				float fft = tex2Dlod(_Noise, float4(sin(_Time.x), cos(_Time.x + sin(_Time.x)), 0, 0)) ;
				float glow = -uv.y * fft * 2.0;
				
				float3 baseCol = float3(s, cos(t * 0.4), -sin(t * 0.24)) * 0.4 + 0.6;
				float3 col = baseCol * m;
				col += baseCol * glow;
				
				#ifdef SIMPLE
					uv *= 10.0;
					col = float3(1.0, 1.0, 1.0) * NetLayer(uv, 0.0, _Time.y);
					uv = frac(uv);
					//if(uv.x>.98 || uv.y>.98) col += 1.;
				#else
					col *= 1. - dot(uv, uv);
					t = fmod(_Time.y, 230.);
					col *= smoothstep(0., 20., t) * smoothstep(224., 200., t);
				#endif
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
