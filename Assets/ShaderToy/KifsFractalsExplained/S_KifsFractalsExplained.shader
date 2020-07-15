Shader "KifsFractalsExplained/S_KifsFractalsExplained"
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
			
			float2 _MousePos;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float2 mouse = _MousePos - 0.5;
				
				float3 col = float3(0, 0, 0);
				
				float angle = 2 / 3.0 * 3.1415;
				float2 n = float2(sin(angle), cos(angle));
				
				float scale = 1.0;
				uv.x += 0.5;
				
				for (int i = 0; i < 5; i ++)
				{
					uv *= 3.0;
					scale *= 3;
					uv.x -= 1.5;
					
					uv.x = abs(uv.x);
					uv.x -= 0.5;
					uv -= n * min(0.0, dot(uv, n)) * 2.0;
				}
				
				float d = length(uv - float2(clamp(uv.x, -1.0, 1.0), 0));
				col += smoothstep(1/_ScreenParams.y, 0, d / scale);
				//col.rg += uv;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
