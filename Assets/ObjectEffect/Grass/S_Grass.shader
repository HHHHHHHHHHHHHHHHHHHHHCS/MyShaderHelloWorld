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
	
	GeometryOutput DRY(float3 pos, float2 uv, float3 localNormal)
	{
		GeometryOutput o;
		o.pos = UnityObjectToClipPos(pos);
		o.uv = uv;
		o._ShadowCoord = ComputeScreenPos(o.pos);
		#if UNITY_PASS_SHADOWCASTER
			o.pos = UnityApplyLinearShadowBias(o.pos);
		#endif
		o.normal = UnityObjectToWorldNormal(localNormal);
		return o;
	}
	
	GeometryOutput GenerateGrassVertex(float3 vertexPosition, float width,
	float height, float forward, float2 uv, float3x3 transformMatrix)
	{
		float3 tangentPoint = float3(width, forward, height);
		float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
		float3 tangentNormal = float3(0, -1, 0);
		float3 localNormal = mul(transformMatrix, tangentNormal);
		return DRY(localPosition, uv, localNormal);
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
		
		for (int i = 0; i < BLADE_SEGMENTS; i ++)
		{
			float t = i / (float) BLADE_SEGMENTS;
			float segmentHeight = height * t;
			float segmentWidth = width * (1 - t);
			float segmentForward = pow(t, _BladeCurve) * forward;
			float3x3 transformMatrix = i == 0?transformMatrixForBottom: transformMatrixForTop;
			triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
			triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
		}
		
		triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformMatrixForTop));
		
		
		//o.pos = UnityObjectToClipPos(pos + float3(0.5,0,0));
		//triStream.Append(DRY(pos + mul(transformMatrixForBottom,float3(width,0,0)),float2(1,0)));
		​
		//o.pos = UnityObjectToClipPos(pos + float3(-0.5,0,0));
		//triStream.Append(DRY(pos + mul(transformMatrixForBottom,float3(-width,0,0)),float2(0,0)));
		​
		//o.pos = UnityObjectToClipPos(pos + float3(0,1,0));
		//triStream.Append(DRY(pos + mul(transformMatrixForTop,float3(0,0,height)),float2(0.5,1)));
		​
		// triStream.Append(GenerateGrassVertex(pos, width, 0, float2(0, 0),transformMatrixForBottom));
		​
		// triStream.Append(GenerateGrassVertex(pos, -width, 0, float2(1, 0), transformMatrixForBottom));
		​
		// triStream.Append(GenerateGrassVertex(pos, 0, height, float2(0.5, 1), transformMatrixForTop));
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
			
			float4 frag(GeometryOutput i, fixed facing: VFACE): SV_TARGET
			{
				float shadow = SHADOW_ATTENUATION(i);
				float3 normal = facing > 0?i.normal: - i.normal;
				float NdotL = saturate(saturate(dot(normal, _WorldSpaceLightPos0)) + _TranslucentGain) * shadow;
				
				float3 ambient = ShadeSH9(float4(normal, 1));
				float4 lightIntensity = NdotL * _LightColor0 + float4(ambient, 1);
				float4 col = lerp(_BottomColor, _TopColor * lightIntensity, i.uv.y);
				
				return col;
			}
			
			ENDCG
			
		}
		
		
		Pass
		{
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma geometry geom
			#pragma hull hull
			#pragma domain domain
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			
			float4 frag(GeometryOutput i): SV_TARGET
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			
			
			ENDCG
			
		}
	}
}
