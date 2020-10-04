Shader "ObjectEffect/S_WaterHD"
{
	Properties
	{
		_MousePos ("Mouse Pos", Vector) = (0, 0, 0)
		_SeaHeight ("Sea Height", float) = 0.6
		_SeaChoppy ("Sea Choppy", float) = 4.0
		_SeaSpeed ("Sea Speed", float) = 0.8
		_SeaFreq ("Sea Freq", float) = 0.16
		_IterGeometry ("Iter Geometry", Range(1, 7)) = 3
		_IterFragment ("Iter Fragment", Range(1, 7)) = 5
		_SeaBaseColor ("Sea Base Color", Color) = (0.1, 0.19, 0.22)
		_SeaWaterColor ("Sea Water Color", Color) = (0.8, 0.9, 0.6)
		_OctaveMatrix ("Octave Martix", Vector) = (1.6, 1.2, -1.2, 1.6)
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
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 scrPos: TEXCOORD0;
			};
			
			
			#define NUM_STEPS   8
			#define PI  3.141592
			#define EPSILON   1e-3
			#define EPSILON_NRM (_ScreenParams.z - 1)
			
			//sea
			float2 _MousePos;
			float _SeaHeight;
			float _SeaChoppy;
			float _SeaSpeed;
			float _SeaFreq;
			float _IterGeometry;
			float _IterFragment;
			float3 _SeaBaseColor;
			float3 _SeaWaterColor;
			float4 _OctaveMatrix;
			
			#define SeaTime (1.0 + _Time.y * _SeaSpeed)
			#define Octave_M float2x2(_OctaveMatrix.xyzw)
			
			float3x3 FromEuler(float3 ang)
			{
				float2 a1 = float2(sin(ang.x), cos(ang.x));
				float2 a2 = float2(sin(ang.y), cos(ang.y));
				float2 a3 = float2(sin(ang.z), cos(ang.z));
				float3x3 m;
				m[0] = float3(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x);
				m[1] = float3(-a2.y * a1.x, a1.y * a2.y, a2.x);
				m[2] = float3(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y);
				return m;
			}
			
			float Hash(float2 p)
			{
				float h = dot(p, float2(127.1, 311.7));
				return frac(sin(h) * 43758.5453123);
			}
			
			float Noise(in float2 p)
			{
				float2 i = floor(p);
				float2 f = frac(p);
				float2 u = f * f * (3.0 - 2.0 * f);
				return - 1.0 + 2.0 * lerp(lerp(Hash(i + float2(0, 0)),
				Hash(i + float2(1.0, 0.0)), u.x),
				lerp(Hash(i + float2(0.0, 1.0)),
				Hash(i + float2(1.0, 1.0)), u.x), u.y);
			}
			
			float Diffuse(float3 n, float3 l, float p)
			{
				return pow(dot(n, l) * 0.4 + 0.6, p);
			}
			
			float Specular(float3 n, float3 l, float3 e, float s)
			{
				float nrm = (s + 8.0) / (PI * 8.0);
				return pow(max(dot(reflect(e, n), l), 0.0), s) * nrm;
			}
			
			//天空盒颜色
			float3 GetSkyColor(float3 e)
			{
				e.y = max(e.y, 0.0);
				return float3(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y) * 0.4);
			}
			
			//用噪音得到高度
			float SeaOctave(float2 uv, float choppy)
			{
				uv += Noise(uv);
				float2 wv = 1.0 - abs(sin(uv));
				float2 swv = abs(cos(uv));
				wv = lerp(wv, swv, wv);
				return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
			}
			
			//海浪的高度  多次叠加
			float Map(float3 p)
			{
				float freq = _SeaFreq;
				float amp = _SeaHeight;
				float choppy = _SeaChoppy;
				float2 uv = p.xz;
				uv.x *= 0.75;
				
				float d, h = 0.0;
				for (int i = 0; i < _IterGeometry; i ++)
				{
					d = SeaOctave((uv + SeaTime) * freq, choppy);
					d += SeaOctave((uv - SeaTime) * freq, choppy);
					h += d * amp;
					uv = mul(uv, Octave_M);
					freq *= 1.9;
					amp *= 0.22;
					choppy = lerp(choppy, 1.0, 0.2);
				}
				return p.y - h;
			}
			
			
			//海浪的细节高度  和 Map 一样
			float MapDetailed(float3 p)
			{
				float freq = _SeaFreq;
				float amp = _SeaHeight;
				float choppy = _SeaChoppy;
				
				float2 uv = p.xz;
				uv.x *= 0.75;
				
				float d, h = 0.0;
				for (int i = 0; i < _IterFragment; i ++)
				{
					d = SeaOctave((uv + SeaTime) * freq, choppy);
					d += SeaOctave((uv - SeaTime) * freq, choppy);
					h += d * amp;
					uv = mul(uv, Octave_M);
					freq *= 1.9;
					amp *= 0.22;
					choppy = lerp(choppy, 1.0, 0.2);
				}
				
				return p.y - h;
			}
			
			//得到水的颜色   lerp(天空颜色,diffuse,fresnel)  + specular
			float3 GetSeaColor(float3 p, float3 n, float3 l, float3 eye, float3 dist)
			{
				float fresnel = clamp(1.0 - dot(n, -eye), 0.0, 1.0);
				fresnel = pow(fresnel, 3.0) * 0.65;
				
				float3 reflected = GetSkyColor(reflect(eye, n));
				float3 refracted = _SeaBaseColor + Diffuse(n, l, 80.0) * _SeaWaterColor * 0.12;
				
				float3 color = lerp(refracted, reflected, fresnel);
				
				float atten = max(1.0 - dot(dist, dist) * 0.001, 0.0);
				color += _SeaWaterColor * (p.y - _SeaHeight) * 0.18 * atten;
				
				float s1 = Specular(n, l, eye, 60.0);
				color += float3(s1, s1, s1);
				
				return color;
			}
			
			float3 GetNormal(float3 p, float eps)
			{
				float3 n;
				n.y = MapDetailed(p);
				n.x = MapDetailed(float3(p.x + eps, p.y, p.z)) - n.y;
				n.z = MapDetailed(float3(p.x, p.y, p.z + eps)) - n.y;
				n.y = eps;
				return normalize(n);
			}
			
			float HeightMapTracing(float3 ori, float3 dir, out float3 p)
			{
				float tm = 0.0;
				float tx = 1000.0;
				float hx = Map(ori + dir * tx);
				if (hx > 0.0)
				{
					return tx;
				}
				float hm = Map(ori + dir * tm);
				float tmid = 0.0;
				for (int i = 0; i < NUM_STEPS; i ++)
				{
					tmid = lerp(tm, tx, hm / (hm - hx));
					p = ori + dir * tmid;
					float hmid = Map(p);
					if(hmid < 0.0)
					{
						tx = tmid;
						hx = hmid;
					}
					else
					{
						tm = tmid;
						hm = hmid;
					}
				}
				return tmid;
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 fragCoord = (i.scrPos.xy / i.scrPos.w) * _ScreenParams.xy;
				
				float2 uv = fragCoord.xy / _ScreenParams.xy;
				uv = uv * 2.0 - 1.0;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float time = _Time.y * 0.3 + _MousePos.x * 0.01;
				
				float3 ang = float3(sin(_Time.y * 3.0) * 0.1, sin(time) * 0.2 + 0.3, time);
				float3 ori = float3(0.0, 3.5, time * 5.0);
				float3 dir = normalize(float3(uv.xy, -2.0));
				dir.z += length(uv) * 0.15;
				dir = mul(normalize(dir), FromEuler(ang));
				
				float3 p;
				HeightMapTracing(ori, dir, p);
				float3 dist = p - ori;
				float3 n = GetNormal(p, dot(dist, dist) * EPSILON_NRM);
				float3 light = normalize(float3(0.0, 1.0, 0.8));
				
				float3 color = lerp(GetSkyColor(dir),
				GetSeaColor(p, n, light, dir, dist),
				pow(smoothstep(0.0, -0.05, dir.y), 0.3));
				
				float3 po = float3(pow(color.x, 0.75), pow(color.y, 0.75), pow(color.z, 0.75));
				return float4(po, 1.0);
			}
			ENDCG
			
		}
	}
}
