Shader "HCS/Triplanar Mapping"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Albedo",2D)="white"{}
		[NoTilingOffest] _MOSMap("MOS",2D)="white"{}
		[NoTilingOffest] _NormalMap ("Normals",2D)="white"{}
		_MapScale("Map Scale",float) = 1
		_BlendOffset("Blend Offset",Range(0,0.5))=0.25
	}

	SubShader
	{
		pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile_instancing

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#define FORWARD_BASE_PASS

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"

			ENDCG
		}

		pass
		{
			Tags{"LightMode"="ForwardAdd"}

			Blend One One
			ZWrite Off

			CGPROGRAM
			
			#pragma target 3.0

			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"

			ENDCG
		}

		pass
		{
			Tags{"LightMode"="Deferred"}

			CGPROGRAM

			#pragma target 3.0
			#pragma exclude_renderers nomrt

			#pragma multi_compile_prepassfinal
			#pragma multi_compile_instancing

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#define DEFERRED_PASS

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"


			ENDCG
		}

		pass
		{
			Tags{"LightMode" = "ShadowCaster"}

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

			#include "My Shadows.cginc"

			ENDCG
		}
	}
}