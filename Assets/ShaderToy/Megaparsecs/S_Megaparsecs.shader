//https://www.shadertoy.com/view/WsyBDz
Shader "ShaderToy/S_Megaparsecs"
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
			
			#define T _Time.y
			
			#if HW_PERFORMANCE == 0
				#define NUMRINGS 20.
				#define MAX_BLOCKS 20.
			#else
				#define NUMRINGS 40.
				#define MAX_BLOCKS 40.
			#endif
			
			float2 _MousePos;
			sampler2D _Noise;
			
			
			float2x2 Rot(float a)
			{
				float s, c;
				sincos(a, s, c);
				return float2x2(c, -s, s, c);
			}
			
			float Hash31(float3 p3)
			{
				p3 = frac(p3 * 0.1031);
				p3 += dot(p3, p3.yzx + 33.33);
				return frac((p3.x + p3.y) * p3.z);
			}
			
			float3 GetRayDir(float2 uv, float3 p, float3 l, float3 up, float z)
			{
				float3 f = normalize(l - p);
				float3 r = normalize(cross(up, f));
				float3 u = cross(f, r);
				float3 c = f * z;
				float3 i = c + uv.x * r + uv.y * u;
				float3 d = normalize(i);
				return d;
			}
			float4 Galaxy(float3 ro, float3 rd, float seed, float a1, float a2, float cut)
			{
				float2x2 rot = Rot(a1);
				ro.xy = mul(ro.xy, rot);
				rd.xy = mul(rd.xy, rot);
				
				rot = Rot(a2);
				ro.yz = mul(ro.yz, rot);
				rd.yz = mul(rd.yz, rot);
				
				float2 uv = ro.xz + (ro.y / - rd.y) * rd.xz;
				seed = frac(sin(seed * 123.42) * 564.32);
				
				
				float3 col = float3(0, 0, 0),
				dustCol = float3(.3, .6, 1.);
				
				float alpha = 0.;
				if (cut == 0. || (ro.y * rd.y < 0. && length(uv) < 2.5))
				{
					
					float ringWidth = lerp(10., 25., seed),
					twist = lerp(.3, 2., frac(seed * 10.)),
					numStars = lerp(2., 15., pow(frac(seed * 65.), 2.)),
					contrast = frac(seed * 3.),
					flip = 1.,
					t = T * .1 * sign(seed - .5),
					z, r, ell, n, d, sL, sN, i;
					
					if (cut == 0.)twist = 1.;
					
					for (i = 0.; i < 1.; i += 1. / NUMRINGS)
					{
						
						flip *= -1.;
						z = lerp(.06, 0., i) * flip * frac(sin(i * 563.2) * 673.2);
						r = lerp(.1, 1., i);
						
						uv = ro.xz + ((ro.y + z) / - rd.y) * rd.xz;
						
						float2 st = mul(uv, Rot(i * 6.2832 * twist));
						st.x *= lerp(2., 1., i);
						
						ell = exp( - .5 * abs(dot(st, st) - r) * ringWidth);
						float2 texUv = .2 * mul(st, Rot(i * 100. + t / r));
						float3
						dust = tex2D(_Noise, texUv + i).rgb,
						dL = pow(ell * dust / r, .5 + contrast);
						
						float2 id = floor(texUv * numStars);
						texUv = frac(texUv * numStars) - .5;
						
						n = Hash31(id.xyy + i);
						
						d = length(texUv);
						
						sL = smoothstep(.5, .0, d) * pow(dL.r, 2.) * .2 / d;
						
						sN = sL;
						sL *= sin(n * 784. + T) * .5 + .5;
						sL += sN * smoothstep(.9999, 1., sin(n * 784. + T * .05)) * 10.;
						col += dL * dustCol;
						
						alpha += dL.r * dL.g * dL.b;
						
						if (i > 3. / numStars)
							col += sL * lerp(float3(.5 + sin(n * 100.) * .5, .5, 1.), 1, n);
					}
					
					col = col / NUMRINGS;
				}
				
				float3
				tint = 1. - float3(pow(seed, 3.), pow(frac(seed * 98.), 3.), 0.) * .5,
				center = (exp( - .5 * dot(uv, uv) * 30.)),
				cp = ro + max(0., dot(-ro, rd)) * rd;
				
				col *= tint;
				
				cp.y *= 4.;
				center += dot(rd, float3(rd.x, 0, rd.z)) * exp( - .5 * dot(cp, cp) * 50.);
				
				col += center * float3(1., .8, .7) * 1.5 * tint;
				
				return half4(col, alpha);
			}
			
			float3 Bg(float3 rd)
			{
				float2 uv = float2(atan2(rd.x, rd.z), rd.y * 0.5 + 0.5);
				uv *= 2.0;
				float wave = sin(rd.y * UNITY_PI + T * 0.1) * 0.5 + 0.5;
				wave *= sin(uv.x + uv.y * UNITY_PI) * 0.5 + 0.5;
				return float3(0.01 * sin(T * 0.06), 0, 0.05) * wave;
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
				float2 uv = (i.vertex - 0.5 * _ScreenParams.xy) / _ScreenParams.y;
				float2 m = _MousePos.xy;
				
				float t = _Time.y * 0.1;
				float dolly = (1.0 - sin(t) * 0.6);
				float zoom = lerp(0.3, 2.0, pow(sin(t * 0.1), 5.0) * 0.5 + 0.5);
				float dO = 0.0;
				
				float3 ro = float3(0.0, 2.0, -2.0) * dolly;
				ro.yz = mul(ro.yz, Rot(m.y * 5.0 + sin(t * 0.5)));
				ro.xz = mul(ro.xz, Rot(-m.x * 5.0 + t * 0.1));
				float3 up = float3(0, 1, 0);
				up.xy = mul(up.xy, Rot(sin(t * 0.2)));
				float3 rd = GetRayDir(uv, ro, float3(0, 0, 0), up, zoom);
				float3 col = Bg(rd);
				float3 dir = sign(rd) * 0.5;
				
				UNITY_LOOP
				for (float i = 0; i < MAX_BLOCKS; i ++)
				{
					float3 p = ro + dO * rd;
					
					p.x += T * 0.2;
					float3 id = floor(p);
					float3 q = frac(p) - 0.5;
					float3 rC = (dir - q) / rd;//ray to cell boundary
					
					float dC = min(min(rC.x, rC.y), rC.z) + 0.0001;//distance to cell just past boundary
					float n = Hash31(id);
					
					dO += dC;
					
					if (n > 0.01)
					{
						continue;
					}
					
					float a1 = frac(n * 67.3) * UNITY_TWO_PI;
					float a2 = frac(n * 653.2) * UNITY_TWO_PI;
					
					col += Galaxy(q * 4.0, rd, n * 100.0, a1, a2, 1.0).rgb * smoothstep(25.0, 10.0, dO);
				}
				
				float4 galaxy = Galaxy(ro, rd, 6.0, 0.0, 0.0, 0.0);
				
				float alpha = pow(min(1.0, galaxy.a * 0.6), 1.0);
				float a = atan2(uv.x, uv.y);
				float sB = sin(a * 13.0 - T) * sin(a * 7.0 + T) * sin(a * 10.0 - T) * sin(a * 4.0 + T);
				float d = length(uv);
				
				sB *= smoothstep(0.0, 0.3, d);
				col = lerp(col, galaxy.rgb * 0.1, alpha * 0.5);
				col += galaxy.rgb;
				col += max(0.0, sB) * smoothstep(5.0, 0.0, dot(ro, ro)) * 0.03 * zoom;
				
				col *= smoothstep(1.0, 0.5, d);
				
				return half4(pow(sqrt(col), 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
