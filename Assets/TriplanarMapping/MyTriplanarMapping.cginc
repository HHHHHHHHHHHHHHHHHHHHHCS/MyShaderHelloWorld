#if !defined(MY_TRIPLANAR_MAPPING_INCLUDED)
#define MY_TRIPLANAR_MAPPING_INCLUDED

#define NO_DEFAULT_UV

#include "My Lighting Input.cginc"

void MyTriPlanarSurfaceFunction(inout SurfaceData surface,SurfaceParameters parameters)
{
	surface.albedo = parameters.normal*0.5+0.5;
}

#define SURFACE_FUNCTION MyTriPlanarSurfaceFunction

#endif