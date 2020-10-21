#ifndef GRASS_TESSELLATION_INCLUDE
	#define GRASS_TESSELLATION_INCLUDE
	
	struct a2v
	{
		float4 vertex: POSITION;
		float3 normal: NORMAL;
		float4 tangent: TANGENT;
	};
	
	struct v2g
	{
		float4 vertex: SV_POSITION;
		float3 normal: NORMAL;
		float4 tangent: TANGENT;
	};

	struct g2t
	{
		float3 edge[3] :SV_TessFactor;
		float inside :SV_InsideTessFactor;
	};

	a2v vert(a2v v)
	{
		return v;
	}

	
	
#endif