Shader "CommonEffect/S_098_Pixelation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_PixelSize ("Pixel Size", Range(0.001, 0.1)) = 0.001
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _PixelSize;
			
			half4 frag(v2f_img i): SV_TARGET
			{
				half4 col;
				
				float ratioX = (int) (i.uv.x / _PixelSize) * _PixelSize;
				float ratioY = (int) (i.uv.y / _PixelSize) * _PixelSize;
				
				col = tex2D(_MainTex, float2(ratioX, ratioY));
				
				//convert to grey scole
				col.r = dot(col.rgb, float3(0.3, 0.59, 0.11));
				
				//original gomeboy rgb color:
				//15,56,15
				//48,98,48
				//139,172,15
				//155,188,15
				
				if (col.r <= 0.25)
				{
					col = half4(0.06, 0.22, 0.06, 1.0);
				}
				else if(col.r > 0.75)
				{
					col = half4(0.6, 0.74, 0.06, 1.0);
				}
				else if(col.r > 0.25 && col.r <= 0.5)
				{
					col = half4(0.19, 0.39, 0.19, 1.0);
				}
				
				return col;
			}
			
			
			
			ENDCG
			
		}
	}
}
