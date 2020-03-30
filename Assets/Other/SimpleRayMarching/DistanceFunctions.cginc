#if !defined(DistanceFunctions_INCLUDED)
	#define DistanceFunctions_INCLUDED
	
	float SDSphere(float3 p, float s)
	{
		return length(p) - s;
	}
	
#endif

