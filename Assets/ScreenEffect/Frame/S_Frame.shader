Shader "ScreenEffect/S_Frame"
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
			
			float Rand(float2 n)
			{
				return frac(sin(dot(n, float2(12.9898, 12.1414))) * 83758.5453);
			}
			
			float Noise(float2 n)
			{
				const float2 d = float2(0.0, 1.0);
				float2 b = floor(n);
				float2 f = lerp(float2(0.0, 0.0), float2(1.0, 1.0), frac(n));
				return lerp(lerp(Rand(b), Rand(b + d.yx), f.x), lerp(Rand(b + d.xy), Rand(b + d.yy), f.x), f.y);
			}
			
			float Fire(float2 n)
			{
				return Noise(n) + Noise(n * 2.1) * 0.6 + Noise(n * 5.4) * 0.42;
			}
			
			float3 Ramp(float t)
			{
				return t <= 0.5?float3(1.0 - t * 1.4, 0.2, 1.05) / t: float3(0.3 * (1.0 - t) * 2.0, 0.2, 1.05) / t;
			}
			
			float3 GetLine(float3 col, float2x2 mtx, float2 uv, float shift)
			{
				float time = _Time.y;
				
				uv = mul(mtx, uv);
				uv.x += uv.y < 0.5?23.0 + time * 0.35: - 11.0 + time * 0.3;
				uv.y = abs(uv.y - shift);
				uv *= 5.0;
				
				float q = Fire(uv - time * 0.013) / 2.0;
				float2 r = float2(Fire(uv + q / 2.0 + time - uv.x - uv.y), Fire(uv + q - time));
				
				float grad = pow((r.y + r.y) * max(0.0, uv.y) + 0.1, 4.0);

				float3 color = 0;//float3(1.0 / (pow(float3(0.5, 0.0, 0.1) + 1.61, 4)));
				color = Ramp(grad);
				color /= (1.50 + max(float3(0, 0, 0), color));
				
				if (color.b < 0.00005)
				{
					color = float3(0, 0, 0);
				}
				
				return lerp(col, color, color.b);
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
				float4 baseColor = tex2D(_MainTex, i.uv);
				
				float3 color = float3(0, 0, 0);
				
				color = GetLine(color, float2x2(1.0, 1.0, 0.0, 1.0), i.uv, 1.02);
				color = GetLine(color, float2x2(1.0, 1.0, 1.0, 0.0), i.uv, 1.02);
				color = GetLine(color, float2x2(1.0, 1.0, 0.0, 1.0), i.uv, -0.02);
				color = GetLine(color, float2x2(1.0, 1.0, 1.0, 0.0), i.uv, -0.02);
				
				return float4(baseColor.rgb + color, baseColor.a);
			}
			ENDCG
			
		}
	}
}
