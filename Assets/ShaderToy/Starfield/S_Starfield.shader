Shader "My/S_Starfield"
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
				o.uv = v.uv;
				return o;
			}
			
			float2x2 Rot(float a)
			{
				float s = sin(a);
				float c = cos(a);
				return float2x2(c, -s, s, c);
			}
			
			float Star(float2 uv, float flare)
			{
				float d = length(uv);
				float m = 0.05 / d;
				
				float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
				m += rays * flare;
				
				uv = mul(Rot(3.1415 / 4.0), uv);
				rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
				m += rays * 0.3 * flare;
				
				return m;
			}
			
			float Hash21(float2 p)
			{
				p = frac(p * float2(123.34, 456.21));
				p += dot(p, p + 45.32);
				return frac(p.x * p.y);
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				uv *= 3;
				
				float3 col = float3(0, 0, 0);
				
				float2 gv = frac(uv) - 0.5;
				float2 id = floor(uv);
				
				for (float y = -1; y <= 1; ++ y)
				{
					for (float x = -1; x <= 1; ++ x)
					{
						float2 offs = float2(x, y);
						float n = Hash21(id + offs); //random between 0 and 1
						col += Star(gv - offs - float2(n, frac(n * 34.0)) + 0.5, 1.0);
					}
				}
				
				//if (gv.x > 0.48 || gv.y > 0.48) col.r = 1.0;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
