#if !defined(MY_SURFACE_INCLUDED)
#define MY_SURFACE_INCLUDED

struct SurfaceData
{
	float3 albedo,emission,normal;
	float alpha,metallic,occlusion,smoothness;
};

struct SurfaceParameters
{
	float3 normal,position;
	float4 uv;
};

#endif