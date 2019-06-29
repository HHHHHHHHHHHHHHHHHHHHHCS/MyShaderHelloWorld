Shader "CommonEffect/S_062_PseudoRandom"
{
	Properties
	{
		_Factor1 ("Factor 1", float) = 1
		_Factor2 ("Factor 2", float) = 1
		_Factor3 ("Factor 3", float) = 1
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
			
			float _Factor1;
			float _Factor2;
			float _Factor3;
			
			float nrand(float2 uv)
			{
				return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
			}
			
			float noise(half2 uv)
			{
				return frac(sin(nrand(uv) * dot(uv + float2(1, 1), float2(_Factor1, _Factor2))) * _Factor3);
			}
			
			half4 frag(v2f_img i): SV_TARGET
			{
				half4 col = noise(i.uv);
				return col;
			}
			
			ENDCG
			
		}
	}
}
