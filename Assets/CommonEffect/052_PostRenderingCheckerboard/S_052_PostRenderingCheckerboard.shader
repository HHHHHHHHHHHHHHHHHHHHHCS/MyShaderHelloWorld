Shader "CommonEffect/S_052_PostRenderingCheckerboard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Color ("Color", Color) = (1, 1, 1, 1)
		[PowerSlider(2.0)]_Val ("Size", Range(0.0, 1)) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			half4 _Color;
			half _Val;
			
			half4 frag(v2f_img i): SV_TARGET
			{
				float2 val = floor(i.pos.xy * _Val) * 0.5;
				
				if (frac(val.x + val.y) > 0)
				{
					return _Color ;
				}
				
				return tex2D(_MainTex, i.uv);
			}
			
			
			ENDCG
			
		}
	}
}
