#if !defined(DistanceFunctions_INCLUDED)
	#define DistanceFunctions_INCLUDED
	
	float SDSphere(float3 p, float s)
	{
		return length(p) - s;
	}
	
	float4 OpUS(float4 d1, float4 d2, float k)
	{
		float h = clamp(0.5 + 0.5 * (d2.w - d1.w) / k, 0.0, 1.0);
		float3 color = lerp(d2.rgb, d1.rgb, h);
		float dist = lerp(d2.w, d1.w, h) - k * h * (1.0 - h);
		return float4(color, dist);
	}
	
#endif

