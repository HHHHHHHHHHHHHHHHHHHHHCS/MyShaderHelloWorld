Shader "CommonEffect/S_025_FixedTessellation"
{
	Properties
	{
		_MainTex("Main Texture (Diffuse)",2D) = "White"{}
		_BumpTex("Normal Map",2D) = "bump"{}
		_DispTex("Displacement Map",2D) = "gray"{}
		_TexVal("Tessellation Value",Range(1,40)) = 1
		_DispVal("Displacement factor",Range(0,1,)) = 0
	}
	SubShader
	{

		Tags{"RenderType"="Opaque"}

		CGPROGRAM

		#pragma surface surf BlinnPhong vertex:vert tessellate:tess
		#pragma target 4.6

		struct a2v
		{
			float4 vertex : POSTION;
			
		}


		ENDCG

	}
}
