Shader "ObjectLight/S_Bumpiness" 
{
	Properties 
	{
		_Tint("Tint ",Color)=(1,1,1,1)
		_MainTex("Albedo",2D)="white"{}
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1
		//[NoScaleOffset] _HeightMap("Heights",2D)="gray"{}
		[Gamma] _Metallic("Metallic",Range(0,1))=0
		_Smoothness("Smoothness",Range(0,1))=0.1
	}
	SubShader 
	{
			pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile _ VERTEXLIGHT_ON

			#pragma vertex vert
			#pragma fragment frag

			#define FORWARD_BASE_PASS

			#include "BumpLight.cginc"

			ENDCG
		}

		pass
		{
			Tags{"LightMode"="ForwardAdd"}

			Blend One One
			ZWrite  Off

			CGPROGRAM
			
			#pragma target 3.0

			#pragma multi_compile_fwdadd 

			#pragma vertex vert
			#pragma fragment frag

			#include "BumpLight.cginc"

			ENDCG
		}

	}
	FallBack off
}
