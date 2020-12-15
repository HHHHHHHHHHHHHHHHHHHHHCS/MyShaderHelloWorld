Shader "ScreenEffect/S_BadVCR"
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
			
			float OnOff(float a, float b, float c)
			{
				float time = _Time.y;
				return step(c, sin(time + a * cos(time * b)));
			}
			
			float4 GetVideo(float2 uv)
			{
				float time = _Time.y;
				float2 look = uv;
				float2 window = 1.0 / (1.0 + 20.0 * (look.y - frac(time / 4.0)) * (look.y - frac(time / 4.0)));
				
				look.x = look.x + sin(look.y * 10.0 + time) / 50.0 * OnOff(4.0, 4.0, 0.3) * (1.0 + cos(time * 80.0)) * window;
				
				float vShift = 0.4 * OnOff(2.0, 3.0, 0.9) * (sin(time) * sin(time * 20.0) + (0.5 + 0.1 * sin(time * 200.0) * cos(time)));
				look.y = frac(look.y + vShift);
				
				float4 video = tex2D(_MainTex, look);
				return video;
			}
			
			float2 ScreenDistort(float2 uv)
			{
				uv -= float2(0.5, 0.5);
				uv = uv * 1.2 * (1.0 / 1.2 + 2.0 * uv.x * uv.x * uv.y * uv.y);
				uv += float2(0.5, 0.5);
				return uv;
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
				float time = _Time.y;
				
				float2 uv = ScreenDistort(i.uv);
				float4 video = GetVideo(uv);
				
				float vigAmt = 3.0 + 0.3 * sin(time + 5.0 * cos(time * 5.0));
				float vignette = (1.0 - vigAmt * (uv.y - 0.5) * (uv.y - 0.5)) * (1.0 - vigAmt * (uv.x - 0.5) * (uv.x - 0.5));
				
				video *= vignette;
				video *= (12.0 + frac(uv.y * 30.0 + time)) / 13.0;
				
				return video;
			}
			ENDCG
			
		}
	}
}
