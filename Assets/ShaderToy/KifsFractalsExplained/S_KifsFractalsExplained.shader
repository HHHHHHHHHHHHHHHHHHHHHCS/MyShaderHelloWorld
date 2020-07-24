Shader "ShaderToy/S_KifsFractalsExplained"
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
			sampler2D _Noise;
			
			float2 N(float angle)
			{
				return float2(sin(angle), cos(angle));
			}
			
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
				
				uv *= 1.25;
				float3 col = float3(0, 0, 0);
				
				uv.x = abs(uv.x);
				uv.y += tan((5.0 / 6.0) * 3.1415) * 0.5;
				
				// tan(a) = y / 0.5 -> y = tan(a) * 0.5
				float2 n = N((5.0 / 6.0) * 3.1415);
				float d = dot(uv - float2(0.5, 0.0), n);
				uv -= n * max(0, d) * 2.0;
				
				//col += smoothstep(0.01, 0.0, abs(d));
				
				n = N(mouse.y * (2.0 / 3.0) * 3.1415);
				float scale = 1.0;
				uv.x += 0.5;
				
				for (int i = 0; i < 4; i ++)
				{
					uv *= 3.0;
					scale *= 3;
					uv.x -= 1.5;
					
					uv.x = abs(uv.x);
					uv.x -= 0.5;
					uv -= n * min(0.0, dot(uv, n)) * 2.0;
				}
				
				d = length(uv - float2(clamp(uv.x, -1.0, 1.0), 0));
				col += smoothstep(1 / _ScreenParams.y, 0, d / scale);
				uv /= scale;
				col += tex2D(_Noise, uv * 2.0 + _Time.y * 0.03).rgb;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
