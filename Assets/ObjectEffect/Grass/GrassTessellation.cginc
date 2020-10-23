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
	
	struct TessellationFactors
	{
		float edge[3]: SV_TessFactor;//细分度
		float inside: SV_InsideTessFactor;//内部细分度
	};
	
	a2v vert(a2v v)
	{
		return v;
	}
	
	v2g tessVert(a2v v)
	{
		v2g o;
		o.vertex = v.vertex;
		o.normal = v.normal;
		o.tangent = v.tangent;
		return o;
	}
	
	float _TessellationUniform;
	
	TessellationFactors patchConstantFunction(InputPatch < a2v, 3 > patch)
	{
		TessellationFactors o;
		o.edge[0] = _TessellationUniform;
		o.edge[1] = _TessellationUniform;
		o.edge[2] = _TessellationUniform;
		o.inside = _TessellationUniform;
		return o;
	}
	
	[UNITY_domain("tri")]
	[UNITY_outputcontrolpoints(3)]
	[UNITY_outputtopology("triangle_cw")]
	[UNITY_partitioning("integer")]
	[UNITY_patchconstantfunc("patchConstantFunction")]
	a2v hull(InputPatch < a2v, 3 > patch, uint id: SV_OutputControlPointID)
	{
		return patch[id];
	}
	
	
	//SV_DomainLocation：由曲面细分阶段阶段传入的顶点位置信息
	[UNITY_domain("tri")]
	v2g domain(TessellationFactors factors, OutputPatch < a2v, 3 > patch, float3 barycentricCoordinates: SV_DomainLocation)
	{
		a2v v;

		#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = \
			patch[0].fieldName * barycentricCoordinates.x + \
			patch[1].fieldName * barycentricCoordinates.y + \
			patch[2].fieldName * barycentricCoordinates.z;

		MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
		MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
		MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)

		return tessVert(v);
	}
	
#endif