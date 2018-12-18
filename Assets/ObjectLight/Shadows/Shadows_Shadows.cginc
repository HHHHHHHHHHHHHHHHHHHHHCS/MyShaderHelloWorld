#if !defined(MY_SHADOWS_INCLUDED)
#define MY_SHADOWS_INCLUDED

#include "UnityCG.cginc"

struct a2v
{
	float4 vertex:POSITION;
	float3 normal:NORMAL;
};




#if defined(SHADOWS_CUBE)

	struct v2f
	{
		float4 pos:SV_POSITION;
		float3 lightVec:TEXCOORD0;
	};

	v2f vert(a2v i)
	{
		v2f o;
		o.pos=UnityClipSpaceShadowCasterPos(i.vertex,i.normal);
		//o.pos=UnityApplyLinearShadowBias(o.pos);
		o.lightVec=mul(unity_ObjectToWorld,i.vertex).xyz-_LightPositionRange.xyz;
		return o;
	}

	fixed4 frag(v2f i):SV_TARGET
	{
		return 0;
	}

#else

	struct v2f
	{
		float4 pos:SV_POSITION;
	};

	v2f vert(a2v i)
	{
		v2f o;
		o.pos=UnityClipSpaceShadowCasterPos(i.vertex,i.normal);
		o.pos=UnityApplyLinearShadowBias(o.pos);
		return o;
	}

	fixed4 frag(v2f i):SV_TARGET
	{
		return 0;
	}

#endif
#endif
