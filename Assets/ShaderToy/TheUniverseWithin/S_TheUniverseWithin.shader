Shader "My/S_TheUniverseWithin"
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
				//避免太长或者太短的线  同时中间过渡
				m *= smoothstep(1.2, 0.8, length(a - b));
				return m;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				//float d = DistLine(uv, float2(0, 0), float2(1, 1));
				//float m = smoothstep(0.1, 0.05, d);
				
				float m = 0;
				
				uv *= 5;
				
				float2 gv = frac(uv) - 0.5;
				float2 id = floor(uv) ;
				
				float2 p[9];
				int index = -1;
				for (float y = -1; y <= 1; ++ y)
				{
					for (float x = -1; x <= 1; ++ x)
					{
						p[ ++ index] = GetPos(id, float2(x, y));
					}
				}
				
				float t = _Time.y * 10;
				for (index = 0; index < 9; ++ index)
				{
					m += Line(gv, p[4], p[index]);
					
					//闪光
					float2 j = (p[index] - gv) * 15;
					float sparkle = 1.0 / dot(j, j);
					m += sparkle * (sin(t + p[index].x * 10.0) * 0.5 + 0.5);
				}
				//连接顶部 底部 对于左右的线
				m += Line(gv, p[1], p[3]);
				m += Line(gv, p[1], p[5]);
				m += Line(gv, p[7], p[3]);
				m += Line(gv, p[7], p[5]);
				
				
				float4 col = float4(0, 0, 0, 1);
				col.rgb = m;
				//测试框
				// if (gv.x > 0.48 || gv.y > 0.48)
				// {
					// 	col.r = 1.0;
					// }
					
					return pow(col, 2.2);
				}
				ENDCG
				
			}
		}
	}
