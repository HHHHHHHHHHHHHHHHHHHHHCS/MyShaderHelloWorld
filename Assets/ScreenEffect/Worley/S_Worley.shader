Shader "ScreenEffect/S_Worley"
{
	Properties
	{
		[HideInInspector]_MainTex ("Texture", 2D) = "white" { }
		
		_Rep ("Rep", Float) = 1.0
		_Chaos ("Chaos", Float) = 1.0
		_CircleBrush ("_CircleBrush", 2D) = "white" { }
		_BrushSize ("BrushSize", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		ZWrite On
		ZTest Always
		
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
			float _Rep;
			sampler2D _CircleBrush;
			float _Chaos;
			float _BrushSize;
			
			inline float N21(float2 p)
			{
				p = frac(p * float2(233.34, 851.73));
				p += dot(p, p + 23.45);
				return frac(p.x * p.y);
			}
			
			inline float2 N22(float2 p)
			{
				float n = N21(p);
				return float2(n, N21(p + n));
			}
			
			inline float2 Random2(float2 p)
			{
				p = p % 289;
				
				float x = float(34 * p.x + 1) * p.x % 289 + p.y;
				x = (34 * x + 1) * x % 289;
				x = frac(x / 41) * 2 - 1;
				return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
			}
			
			float4 Worley(float2 p, float rep)
			{
				float2 sp = p * rep;
				float2 p_int0 = floor(sp);
				float4 result = 0;
				
				for (int m = -1; m < 3; ++ m)
				{
					for (int n = -1; n < 3; ++ n)
					{
						float2 newP_int0 = p_int0 + float2(m, n);
						newP_int0 += (Random2(newP_int0) * 2 - 1) * _Chaos;
						
						float2 sobelDir = (newP_int0 / rep) - p;//Sobel(newP_int0 / rep);/可以用这个算法替代
						sobelDir = float2(sobelDir.y, -sobelDir.x);
						
						if (abs(sobelDir.x) <= 0.02)
						{
							sobelDir.x = sign(sobelDir.x) * 0.02;
						}
						
						float angle = atan(sobelDir.y / sobelDir.x);
						float c, s;
						sincos(angle, c, s);
						
						float2x2 rotateMatrix = {
							c, -s,
							s, c
						};
						
						float edge = saturate(sobelDir.y * sobelDir.y + sobelDir.x * sobelDir.x);
						edge = 1 - edge;
						edge = edge * edge;
						
						float2 offset = (sp - newP_int0) / (4.242 * _BrushSize * edge);
						offset = mul(rotateMatrix, offset);
						offset = clamp(offset, -0.5, 0.5) + 0.5;
						
						float a = tex2Dlod(_CircleBrush, float4(offset, 0, 0)).a;
						float4 brushCol = tex2D(_MainTex, newP_int0 / rep);
						
						result.rgb += a * brushCol.rgb;
						result.a += a;
					}
				}
				
				if (result.a >= 1)
				{
					result /= result.a;
				}
				else
				{
					result.rgb += (1 - result.a) * tex2D(_MainTex, p).rgb;
					result.a = 1;
				}
				
				
				return result;
			}
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = Worley(i.uv, _Rep);
				return col;
			}
			ENDCG
			
		}
	}
}
