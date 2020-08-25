Shader "ShaderToy/S_ToursKnots"
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
			
			#define MAX_STEPS 100
			#define MAX_DIST 100.0
			#define SURF_DIST 0.001
			
			float2x2 Rot(float a)
			{
				float s = sin(a);
				float c = cos(a);
				return float2x2(c, -s, s, c);
			}
			
			float Hash21(float2 p)
			{
				p = frac(p * float2(123.34, 233.53));
				p += dot(p, 23.234);
				return frac(p.x * p.y);
			}
			
			float SDBox(float3 p, float3 s)
			{
				p = abs(p) - s;
				//min(max max) 的作用是 如果在内部
				return length(max(p, 0.0)) + min(max(p.x, max(p.y, p.z)), 0.0);
			}
			
			float SDBox2D(float2 p, float2 s)
			{
				p = abs(p) - s;
				return length(max(p, 0.0)) + min(max(p.x, p.y), 0.0);
			}
			
			float GetDist(float3 p)
			{
				
				float r1 = 1.7;
				float r2 = 0.2;
				float2 cp = float2(length(p.xz) - r1, p.y);
				float d = length(cp) - r2;
				
				return d;
				
				/*
				float r1 = 1.7;
				float r2 = 0.3;
				float2 cp = float2(length(p.xz) - r1, p.y);
				float a = atan2(p.x, p.z);//-pi,pi
				cp = mul(Rot(a * 2.5 + _Time.y * 0.5), cp);
				cp.y = abs(cp.y) - 0.4;
				
				float d = length(cp) - r2;
				d = SDBox2D(cp, float2(0.1, 0.3 * (sin(4.0 * a) * 0.5 + 0.5))) - 0.1;
				
				return d * 0.6;
				*/
			}
			
			float RayMarch(float3 ro, float3 rd)
			{
				float dO = 0.0;;
				
				for (int i = 0; i < MAX_STEPS; i ++)
				{
					float3 p = ro + rd * dO;
					float dS = GetDist(p);
					dO += dS;
					if (dO > MAX_DIST || abs(dS) < SURF_DIST)
					{
						break;
					}
				}
				
				return dO;
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
				float3 c = f * z;
				float3 i = c + uv.x * r + uv.y * u;
				float3 d = normalize(i);
				return d;
			}
			
			float3 Bg(float3 rd)
			{
				float k = rd.y * 0.5 + 0.5;
				
				float3 col = lerp(float3(0.2, 0.1, 0.1), float3(0.2, 0.5, 1), k);
				
				return col;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos;
				
				float3 col = float3(0, 0, 0);
				
				float3 ro = float3(0, 4, -4);
				
				ro.yz = mul(Rot(-m.y * 3.1415 / 2.0), ro.yz);
				ro.xz = mul(Rot(-m.x * 6.2831), ro.xz);
				
				float3 rd = GetRayDir(uv, ro, float3(0, 0, 0), 1.0);
				
				col += Bg(rd);
				
				float d = RayMarch(ro, rd);
				
				if(d < MAX_DIST)
				{
					float3 p = ro + rd * d;
					float3 n = GetNormal(p);
					float3 r = reflect(rd, n);
					
					float spec = pow(max(0.0, r.y), 30.0);
					float dif = dot(n, normalize(float3(1, 2, 3))) * 0.5 + 0.5;
					//col = lerp(Bg(r), float3(dif, dif, dif), 0.5) + spec;
					col = float3(dif, dif, dif);
				}
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
