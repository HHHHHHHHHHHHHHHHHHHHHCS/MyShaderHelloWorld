Shader "HCS/S_LensFlare_Bloom"
{
	Properties
	{
		_MainTex ("", 2D) = "" { }
		_BasetTex ("", 2D) = "" { }
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	//手机:使用RGBM 代替 float/half RGB
	#define USE_RGBM defined(SHADER_API_MOBILE)
	
	sampler2D _MainTex;
	sampler2D _BasetTex;
	float2 _MainTex_TexelSize;
	float2 _BaseTex_TexelSize;
	half4 _MainTex_ST;
	half4 _BaseTex_ST;
	
	float _PrefilterOffs;
	half _Threshold;
	half3 _Curve;
	float _SampleScale;
	half _Intensity;
	
	sampler2D _DirtTex;
	half _DirtIntensity;
	
	ENDCG
	
	SubShader { }
}
