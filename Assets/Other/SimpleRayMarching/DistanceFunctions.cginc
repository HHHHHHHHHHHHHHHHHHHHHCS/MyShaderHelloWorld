#if !defined(DistanceFunctions_INCLUDED)
	#define DistanceFunctions_INCLUDED
	
	// Sphere
	// p:point  s:radius
	float SDSphere(float3 p, float s)
	{
		return length(p) - s;
	}
	
	// Box
	// b:box size xyz
	float SDBox(float3 p, float b)
	{
		float3 d = abs(p) - b;
	}
	
	// Plane
	// n need normalized  .w offset
	float SDPlane(float3 p, float4 n)
	{
		return dot(p, n.xyz) + n.w;
	}
	
	float4 OpUS(float4 d1, float4 d2, float k)
	{
		float h = clamp(0.5 + 0.5 * (d2.w - d1.w) / k, 0.0, 1.0);
		float3 color = lerp(d2.rgb, d1.rgb, h);
		float dist = lerp(d2.w, d1.w, h) - k * h * (1.0 - h);
		return float4(color, dist);
	}
	
	float OpSS(float d1, float d2, float k)
	{
		float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
		return lerp(d2, -d1, h) + k * h * (1.0 - h);
	}
	
	float OpIS(float d1, float d2, float k)
	{
		float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
		return lerp(d2, d1, h) + k * h * (1.0 - h);
	}
	
#endif

