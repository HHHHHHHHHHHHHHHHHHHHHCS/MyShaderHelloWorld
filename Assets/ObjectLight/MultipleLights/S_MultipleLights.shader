Shader "HCS/S_MultipleLights" 
{
	Properties 
	{
		_Tint("Main Color",color)=(1,1,1,1)
		_MainTex ("Main Map", 2D) = "white" {}
		[Gamma] _Metallic("Metallic",Range(0,1))=0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
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

			#include "MultipleLights.cginc"

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

			#include "MultipleLights.cginc"

			ENDCG
		}

	}
	FallBack off
}
