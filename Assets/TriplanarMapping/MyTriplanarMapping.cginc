#if !defined(MY_TRIPLANAR_MAPPING_INCLUDED)
#define MY_TRIPLANAR_MAPPING_INCLUDED

#define NO_DEFAULT_UV

#include "My Lighting Input.cginc"

struct TriplanarUV
{
	float2 x,y,z;
};

sampler2D _MOHSMap,_TopMainTex,_TopMOHSMap,_TopNormalMap;
float _MapScale,_BlendOffset,_BlendExponent,_BlendHeightStrength;

TriplanarUV GetTriplanarUV(SurfaceParameters parameters)
{
	TriplanarUV triUV;
	float3 p = parameters.position*_MapScale;
	triUV.x = p.zy;
	triUV.y = p.xz;
	triUV.z = p.xy;

	if(parameters.normal.x<0)
	{
		triUV.x.x = -triUV.x.x;
	}
	if(parameters.normal.y<0)
	{
		triUV.y.x = -triUV.y.x;
	}
	if(parameters.normal.z>=0)
	{
		triUV.z.x = -triUV.z.x;
	}
	triUV.x.y += 0.5;
	triUV.z.x += 0.5;
	return triUV;
}

float3 GetTriplanarWeights(SurfaceParameters parameters,float heightX,float heightY,float heightZ)
{
	float3 triW = abs(parameters.normal);
	triW = saturate(triW - _BlendOffset);
	triW *= lerp(1,float3(heightX,heightY,heightZ),_BlendHeightStrength);
	triW = pow(triW,_BlendExponent);
	return triW/(triW.x+triW.y+triW.z);
}

float3 BlendTriplanarNormal(float3 mappedNormal,float3 surfaceNormal)
{
	float3 n;
	n.xy = mappedNormal.xy+surfaceNormal.xy;
	n.z = mappedNormal.z*surfaceNormal.z;
	return n;
}


void MyTriPlanarSurfaceFunction(inout SurfaceData surface,SurfaceParameters parameters)
{
	TriplanarUV triUV = GetTriplanarUV(parameters);

	float3 albedoX = tex2D(_MainTex,triUV.x).rgb;
	float3 albedoY = tex2D(_MainTex,triUV.y).rgb;
	float3 albedoZ = tex2D(_MainTex,triUV.z).rgb;

	float4 mohsX = tex2D(_MOHSMap,triUV.x);
	float4 mohsY = tex2D(_MOHSMap,triUV.y);
	float4 mohsZ = tex2D(_MOHSMap,triUV.z);

	float3 tangentNormalX = UnpackNormal(tex2D(_NormalMap,triUV.x));
	float4 rawNormalY = tex2D(_NormalMap,triUV.y);
	float3 tangentNormalZ = UnpackNormal(tex2D(_NormalMap,triUV.z));

	#if defined (_SEPARATE_TOP_MAPS)
		if (parameters.normal.y>0)
		{
			albedoY = tex2D(_TopMainTex,triUV.y).rgb;
			mohsY = tex2D(_TopMOHSMap,triUV.y);
			rawNormalY = tex2D(_TopNormalMap,triUV.y);
		}
	#endif
	float3 tangentNormalY = UnpackNormal(rawNormalY);

	if(parameters.normal.x<0)
	{
		tangentNormalX.x = -tangentNormalX.x;
	}
	if(parameters.normal.y<0)
	{
		tangentNormalY.x = -tangentNormalY.x;
	}
	if(parameters.normal.z>=0)
	{
		tangentNormalZ.x = -tangentNormalZ.x;
	}

	float3 worldNormalX = BlendTriplanarNormal(tangentNormalX,parameters.normal.zyx).zyx;
	float3 worldNormalY = BlendTriplanarNormal(tangentNormalY,parameters.normal.xzy).xzy;
	float3 worldNormalZ = BlendTriplanarNormal(tangentNormalZ,parameters.normal); 

	float3 triW = GetTriplanarWeights(parameters,mohsX.z,mohsY.z,mohsZ.z);

	surface.albedo = albedoX * triW.x + albedoY * triW.y + albedoZ * triW.z;
	surface.normal=normalize(worldNormalX*triW.x+worldNormalY*triW.y+worldNormalZ*triW.z);
	//surface.albedo = triW;

	float4 mohs = mohsX*triW.x+mohsY*triW.y+mohsZ*triW.z;
	surface.metallic = mohs.x;
	surface.occlusion=mohs.y;
	surface.smoothness = mohs.a;
}

#define SURFACE_FUNCTION MyTriPlanarSurfaceFunction

#endif