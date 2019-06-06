Shader "CommonEffect/S_034_CosmicEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Zoom ("Zoom", Range(0.5, 20)) = 1
		_Speed ("Speed", Range(0.01, 10)) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			half _Zoom;
			half _Speed;
			
			float4 vert(appdata_base v): SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}
			
			half4 frag(float4 i: SV_POSITION): SV_TARGET
			{
				// xy是当前渲染目标在像素值中宽度高度 
				return tex2D(_MainTex, float2((i.xy / _ScreenParams.xy) + float2(_CosTime.x * _Speed, _SinTime.x * _Speed) / _Zoom));
			}
			
			
			ENDCG
			
		}
	}
}
