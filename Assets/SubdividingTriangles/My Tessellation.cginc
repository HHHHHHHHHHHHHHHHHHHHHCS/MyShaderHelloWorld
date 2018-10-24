#if !defined(TESSELLATION_INCLUED)
	#define TESSELLATION_INCLUED

	struct TessellationFactors
	{
		float edge[3] : SV_TessFactor;
		float inside : SV_InsideTessFactor;
	};


	[UNITY_domain("tri")]
	[UNITY_outputcontrolpoints(3)]
	[UNITY_outputtopology("triangle_cw")]
	[UNITY_partitioning("integer")]
	[UNITY_patchconstantfunc("MyPatchConstantFunction")]
	VertexData MyHullProgram (InputPatch<VertexData,3> patch,uint id:SV_OutputControlPointID) 
	{
		return patch[id];
	}

	TessellationFactors MyPatchConstantFunction(InputPatch<VertexData,3> patch)
	{
		TessellationFactors f;
		f.edge[0]=1;
		f.edge[1]=1;
		f.edge[2]=1;
		f.inside=1;
		return f;
	}

	[UNITY_domain("tri")]
	void MyDomainProgram(TessellationFactors factors,OutputPatch<VertexData,3> patch
		,float3 barycentriCoordinates:SV_DOMAINLOCATION)
	{
		VertexData data;

		#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
			patch[0].vertex*barycentriCoordinates.x + \
			patch[1].vertex*barycentriCoordinates.y + \
			patch[2].vertex*barycentriCoordinates.z;

		MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
	}

#endif