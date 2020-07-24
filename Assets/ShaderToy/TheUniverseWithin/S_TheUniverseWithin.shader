Shader "ShaderToy/S_TheUniverseWithin"
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
			sampler2D _Noise;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float DistLine(float2 p, float2 a, float2 b)
			{
				float2 pa = p - a;
				float2 ba = b - a;
				float t = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
				return length(pa - ba * t);
			}
			
			float N21(float2 p)
			{
				p = frac(p * float2(233.34, 851.73));
				p += dot(p, p + 23.45);
				return frac(p.x * p.y);
			}
			
			float2 N22(float2 p)
			{
				float n = N21(p);
				return float2(n, N21(p + n));
			}
			
			float2 GetPos(float2 id, float2 offs)
			{
				float2 n = N22(id + offs) * _Time.y;
				return offs + sin(n) * 0.4;//本来是偏移位置 加上offs 就是在格子上离(0,0)的位置
			}
			
			float Line(float2 p, float2 a, float2 b)
			{
				float d = DistLine(p, a, b);
				float m = smoothstep(0.03, 0.01, d);
				float d2 = length(a - b);
				//避免太长或者太短的线  同时中间过渡
				m *= smoothstep(1.2, 0.8, length(a - b)) * 0.5
				+ smoothstep(0.05, 0.03, abs(d2 - 0.75));
				return m;
			}
			
			float Layer(float2 uv)
			{
				float m = 0;
				float2 gv = frac(uv) - 0.5;
				float2 id = floor(uv) ;
				
				float2 p[9];
				int i = 0;
				for (float y = -1; y <= 1; ++ y)
				{
					for (float x = -1; x <= 1; ++ x)
					{
						p[ i ++ ] = GetPos(id, float2(x, y));
					}
				}
				
				float t = _Time.y * 10;
				for (i = 0; i < 9; ++ i)
				{
					m += Line(gv, p[4], p[i]);
					
					//闪光
					float2 j = (p[i] - gv) * 15.0;
					float sparkle = 1.0 / dot(j, j);
					m += sparkle * (sin(t + p[i].x * 10.0) * 0.5 + 0.5);
				}
				//连接顶部 底部 对于左右的线
				m += Line(gv, p[1], p[3]);
				m += Line(gv, p[1], p[5]);
				m += Line(gv, p[7], p[3]);
				m += Line(gv, p[7], p[5]);
				
				return m;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float2 mouse = _MousePos - 0.5;
				
				float gradient = uv.y;
				
				float m = 0;
				float t = _Time.x;
				float s, c;
				sincos(t, s, c);
				float2x2 rot = float2x2(c, -s, s, c);
				uv = mul(rot, uv);
				mouse = mul(rot, mouse);
				
				for (float i = 0.0; i < 1.0; i += 0.25)
				{
					float z = frac(i + t);
					float size = lerp(10.0, 0.5, z);
					//过小 或者 过大 都会变淡
					float fade = smoothstep(0.0, 0.5, z)
					* smoothstep(1.0, 0.8, z);
					m += Layer(uv * size + i * 20 - mouse) * fade;
				}
				
				float3 base = sin(t * 5.0 * float3(0.096, 0.178, 0.397)) * 0.4 + float3(0.325, 0.325, 0.325);
				float3 col = m * base;
				float fft = tex2Dlod(_Noise, float4(sin(_Time.x), cos(_Time.x + sin(_Time.x)), 0, 0)) ;
				gradient *= fft * 0.5;
				col -= gradient * base;
				//测试框
				/*
				if (uv.x > 0.48 || uv.x > 0.48)
				{
					col.r = 1.0;
				}
				*/
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
