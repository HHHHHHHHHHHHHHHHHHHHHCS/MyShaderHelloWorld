Shader "ShaderToy/S_Firework"
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
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float2 uv = (i.uv - 0.5) * _ScreenParams.xy / _ScreenParams.y;
				
				half3 col = 0;
				
				for (float i = 0.0; i < NUM_EXPLOSIONS; ++ i)
				{
					float t = _Time.y + i / NUM_EXPLOSIONS;
					float ft = floor(t);
					half3 color = sin(half3(0.34, 0.54, 0.43) * ft + float3(1.1244, 3.43215, 6.435)) * 0.5 + 0.5;
					float2 offs = Hash12(i + 1.0 + ft) - 0.5;
					offs *= float2(1.77, 1.0);
					//col += 0.0004 / length(uv - offs);
					col += Explosion(uv - offs, frac(t)) * color;
				}
				
				col *= 2.0;
				
				col = pow(col, 2.2);
				
				
				return half4(col, 1);
			}
			ENDCG
			
		}
	}
}
