Shader "CommondEffect/S_049_Spotlight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_CenterX ("Center X", Range(0.0, 0.5)) = 0.25
		_CenterY ("Center Y", Range(0.0, 0.5)) = 0.25
		_Radius ("Radius", Range(0.01, 0.5)) = 0.1
		_Sharpness ("Sharpness", Range(1, 20)) = 1
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
			float _CenterX, _CenterY;
			float _Radius;
			float _Sharpness;
			
			half4 frag(v2f_img i): SV_TARGET
			{
				float dist = distance(float2(_CenterX, _CenterY), ComputeScreenPos(i.pos).xy / _ScreenParams.x);
				half4 col = tex2D(_MainTex, i.uv);
				return col * saturate((1 - pow(dist / _Radius, _Sharpness)));
			}
			
			ENDCG
			
		}
	}
}
