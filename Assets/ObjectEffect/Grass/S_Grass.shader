Shader "ObjectEffect/S_Grass"
{
	Properties
	{
		_BottomColor ("Bottom Color", Color) = (1, 1, 1, 1)
		_TopColor ("Top Color", Color) = (1, 1, 1, 1)
		_BendRotationRandom ("Bend Rotation Random", Range(0, 1)) = 0.2
		_BladeWidth ("Blade Width", Float) = 0.05
		_BladeWidthRandom ("Blade Width Random", Float) = 0.02
		_BladeHeight ("Blade Height", Float) = 0.5
		_BladeHeightRandom ("Blade Height Random", Float) = 0.3
		_TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 1
		_WindDistortionMap ("Wind Distortion Map", 2D) = "white" { }
		_WindFrequency ("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
		_WindStrength ("Wind Strength", Float) = 1
		_BladeForward ("Blade Forward Amount", Float) = 0.38
		_BladeCurve ("Blade Curvature Amount", Range(1, 4)) = 2
		_TranslucentGain ("Translucent Gain", Range(0, 1)) = 0.5
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
	#include "GrassTessellation.cginc"
	
	#define BLADE_SEGMENTS 3
	
	struct GeometryOutput
	{
		float4 pos: SV_POSITION;
		float2 uv: TEXCOORD0;
		float3 normal: NORMAL;
		unityShadowCoord4 _ShadowCoord: TEXCOORD1;
	}
	
	float4 _BottomColor, _TopColor;
	half _BendRotationRandom;
	float _BladeHeight;
	float _BladeHeightRandom;
	float _BladeWidth;
	float _BladeWidthRandom;
	sampler2D _WindDistortionMap;
	float4 _WindDistortionMap_ST;
	float2 _WindFrequency;
	float _WindStrength;
	float _BladeForward;
	float _BladeCurve;
	float _TranslucentGain;
	
	//rand flaot3->float(0,1)
	float rand(float3 co)
	{
		return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
	}
	
	float3x3 AngleAxis3x3(float angle, float3 axis)
	{
		float c, s;
		sincos(angle, s, c);
		
		float t = 1 - c;
		float x = axis.x;
		float y = axis.y;
		float z = axis.z;
		
		return float3x3(
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c
		);
	}
	
	[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
	void geom(triangle v2g i[3], inout TriangleStream < g2t > triStream)
	{
		g2t o;
		float3 pos = i[0].vertex;
		float3 vNormal = i[0].normal;
		float3 vTangent = i[0].tangent;
		float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
		
		float3x3 tangentToLocal = float3x3(
			vTangent.x, vBinormal.x, vNormal.x,
			vTangent.y, vBinormal.y, vNormal.y,
			vTangent.z, vBinormal.z, vNormal.z
		);
		
		//z rotation
		float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
		
		//x rotation
		float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzy)) * UNITY_PI * 0.5 * _BendRotationRandom, float3(1, 0, 0));
		
		//wind
		float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
		float2 windSample = (tex2Dlod(_WindDistortionMap, flaot4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
		float3 wind = normalize(float3(windSample.x, windSample.y, 0));
		float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);
		
		float3x3 transformMatrixForTop = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
		
		float3x3 transformMatrixForBottom = mul(tangentToLocal, facingRotationMatrix);
		
		float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRnadom + _BladeHeight;
		float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
		
		float forward = rand(pos.yyz) * _BladeForward;
	}
	
	ENDCG
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		Cull Off
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma geomerty geom
			#pragma hull hull
			#pragma domain domain
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			ENDCG
			
		}
	}
}
