Shader "HCS/Triplanar Mapping"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Albedo",2D)="white"{}
		[NoTilingOffest] _MOHSMap("MOHS",2D)="white"{}
		[NoTilingOffest] _NormalMap ("Normals",2D)="white"{}

		[NoScaleOffest] _TopMainTex("Top Albedo",2D)="white"{}
		[NoScaleOffest] _TopMOHSMap("Top MOHS",2D)="white"{}
		[NoScaleOffest] _TopNormalMap("Top Normals",2D)="white"{}

		_MapScale("Map Scale",float) = 1
		_BlendOffset("Blend Offset",Range(0,0.5))=0.25
		_BlendExponent("Blend Exponent",Range(1,8))=2
		_BlendHeightStrength("Blend Height Strength",Range(0,0.99))=0.5
	}

	SubShader
	{
		pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma target 3.0

			#pragma shader_feature _SEPARATE_TOP_MAPS

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

			#pragma shader_feature _SEPARATE_TOP_MAPS

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
			#pragma shader_feature _SEPARATE_TOP_MAPS

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
			#pragma shader_feature _SEPARATE_TOP_MAPS

			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

			#include "My Shadows.cginc"

			ENDCG
		}

		pass
		{
			Tags{"LightMode"="Meta"}

			Cull Off

			CGPROGRAM
			#pragma vertex MyLightmappingVertexProgram
			#pragma fragment MyLightmappingFragmentProgram

			#pragma shader_feature _SEPARATE_TOP_MAPS

			#define META_PASS_NEEDS_NORMAL
			#define META_PASS_NEEDS_POSITION

			#include "MyTriplanarMapping.cginc"
			#include "My Lightmapping.cginc"

			ENDCG
		}
	}

	CustomEditor "MyLightingShaderGUI_TriplanarMapping_TM"
}