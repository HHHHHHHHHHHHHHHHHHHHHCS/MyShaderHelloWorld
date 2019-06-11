Shader "CommonEffect/S_042_VaryingColor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_RampTex ("Ramp Texture", 2D) = "white" { }
		_Speed ("Speed", Range(1, 10)) = 1
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
			sampler2D _RampTex;
			float _Speed;
			
			
			half4 frag(v2f_img i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				return tex2D(_RampTex, half2(frac(col.r + _Time.x * _Speed), 0.5));
			}
			
			ENDCG
			
		}
	}
}
