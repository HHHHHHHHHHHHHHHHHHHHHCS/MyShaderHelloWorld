Shader "MakeAHeart/S_MakeAHeart"
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
			
			float2 _MousePos;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float smax(float a, float b, float k)
			{
				float h = clamp((b - a) / k + 0.5, 0.0, 1.0);
				return lerp(a, b, h) + h * (1.0 - h) * k * 0.5;
			}
			
			float Heart(float2 uv, float b)
			{
				float r = 0.25;
				b *= r;
				
				uv.x *= 0.7;
				uv.y -= smax(sqrt(abs(uv.x)) * 0.5, b, 0.1);
				uv.y += 0.1;
				float d = length(uv);
				
				return smoothstep(r + b, r - b - 1e-6, d);
			}
			
			float4 frag(v2f input): SV_Target
			{
				const float3 heartColor = float3(1.0, 0.05, 0.05);
				
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos;
				
				float3 col = float3(0, 0, 0);
				
				float c = Heart(uv, m.y);
				
				col = float3(c * heartColor);
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
