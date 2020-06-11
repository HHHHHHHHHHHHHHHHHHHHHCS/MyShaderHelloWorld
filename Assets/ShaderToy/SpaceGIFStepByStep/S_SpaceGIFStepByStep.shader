Shader "SpaceGIFStepByStep/S_SpaceGIFStepByStep"
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
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float Xor(float a, float b)
			{
				return a * (1.0 - b) + b * (1.0 - a);
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = ((i.uv - 0.5) * _ScreenParams.xy) / _ScreenParams.y;
				
				float3 col = 0;
				
				float a = 0.78;
				float s, c;
				sincos(a, s, c);
				
				uv = mul(uv, float2x2(c, -s, s, c));
				uv *= 15.0;
				
				float2 gv = frac(uv) - 0.5;
				float2 id = floor(uv);
				
				float m = 0;
				
				float step = _ScreenParams.z - 1;
				
				UNITY_UNROLL
				for (float y = -1.0; y <= 1.0; ++ y)
				{
					UNITY_UNROLL
					for (float x = -1.0; x <= 1.0; ++ x)
					{
						float2 offs = float2(x, y) ;
						
						float d = length(gv - offs);
						float2 dist = length(id + offs) * 0.3;
						
						float r = lerp(0.3, 1.5, sin(dist - _Time.z) * 0.5 + 0.5);
						m = Xor(m, smoothstep(r, r * 0.9, d));
					}
				}
				
				//col.rg = gv;
				col += m;//fmod(m, 2.0);
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
