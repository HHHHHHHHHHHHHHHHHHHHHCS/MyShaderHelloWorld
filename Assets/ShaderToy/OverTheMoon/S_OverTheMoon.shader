Shader "ShaderToy/S_OverTheMoon"
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
			
			float TaperBox(float2 p, float wb, float wt, float yb, float yt, float blur)
			{
				float m = smoothstep(-blur, blur, p.y - yb);
				m *= smoothstep(blur, -blur, p.y - yt);
				
				p.x = abs(p.x);
				// 0 p.y = yb    1 p.y = yt
				float w = lerp(wb, wt, (p.y - yb) / (yt - yb));
				m *= smoothstep(blur, -blur, p.x - w);
				
				return m;
			}
			
			float4 Tree(float2 uv, float x, float y, float3 col, float blur)
			{
				//uv -= float2(x, y);
				float m = TaperBox(uv, 0.03, 0.03, -0.5, 0.25, blur); //trunk
				m += TaperBox(uv, 0.2, 0.1, 0.25, 0.5, blur);//canopy 1
				m += TaperBox(uv, 0.15, 0.05, 0.5, 0.75, blur);//canopy 2
				m += TaperBox(uv, 0.1, 0.0, 0.75, 1.0, blur);//top
				
				float shadow = TaperBox(uv - float2(0.2, 0.0), 0.1, 0.5, 0.15, 0.25, blur);
				shadow += TaperBox(uv + float2(0.25, 0.0), 0.1, 0.5, 0.45, 0.5, blur);
				shadow += TaperBox(uv + float2(0.25, 0.0), 0.1, 0.5, 0.7, 0.75, blur);
				
				col -= shadow * 0.8;
				
				return float4(col, m);
			}
			
			float GetHeight(float x)
			{
				return sin(x * 0.423) + sin(x) * 0.3;
			}
			
			float4 Layer(float2 uv, float blur)
			{
				float4 col = 0;
				
				float id = floor(uv.x);
				float n = frac(sin(id * 234.12) * 5463.3) * 2.0 - 1.0;
				float x = n * 0.3;
				float y = GetHeight(uv.x);
				
				float ground = smoothstep(blur, -blur, uv.y + y);//ground
				col += ground;
				
				y = GetHeight(id + 0.5 + x);
				uv.x = frac(uv.x) - 0.5;
				
				float4 tree = Tree((uv - float2(x, -y)) * float2(1.0, 1.0 + n * 0.2), x, -y, float3(1, 1, 1), blur);
				//col.rg = uv;
				col.rgb = lerp(col.rgb, tree.rgb, tree.a);
				col.a = max(ground, tree.a);
				return col;
			}
			
			float Hash21(float2 p)
			{
				p = frac(p * float2(234.45, 765.34));
				p += dot(p, p + 547.123);
				return frac(p.x * p.y);
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
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos * 2.0 - 1.0;
				
				
				float t = _Time.y * 0.3;
				
				
				float4 col = 0;
				
				float twinkle = dot(length(sin(uv + t)), length(cos(uv * float2(22, 6.7) - t * 3.0)));
				twinkle = sin(twinkle * 10.0) * 0.5 + 0.5;
				float stars = pow(Hash21(uv), 100) * twinkle;
				col += stars;
				//col += twinkle;
				
				float moon = smoothstep(0.01, -0.01, length(uv - float2(0.4, 0.2)) - 0.15);
				col *= 1.0 - moon;
				moon *= smoothstep(-0.01, 0.1, length(uv - float2(0.5, 0.25)) - 0.15);
				col += moon;
				
				float4 layer = 0;
				float blur = 0.005;
				
				
				for (float i = 0; i < 1.0; i += 1.0 / 10.0)
				{
					float scale = lerp(30.0, 1.0, i);
					blur = lerp(0.1, 0.005, i);
					layer = Layer(uv * scale + float2(t + i * 100, 0) - m, blur);
					
					layer.rgb *= (1.0 - i) * float3(0.9, 0.9, 1.0);
					
					col = lerp(col, layer, layer.a);
				}
				
				layer = Layer(uv + float2(t, 0) - m, 0.07);
				col = lerp(col, layer * 0.1, layer.a);
				
				float thickness = 1.0 / _ScreenParams.y;
				
				/*
				if (abs(uv.x) < thickness)
				{
					col.g = 1.0;
				}
				if(abs(uv.y) < thickness)
				{
					col.r = 1.0;
				}
				*/
				
				return float4(pow(col.rgb, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
