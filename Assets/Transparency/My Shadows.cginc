#if !defined(MY_SHADOWS_INCLUDED)
#define MY_SHADOWS_INCLUDED

#include "UnityCG.cginc"

#if defined(_RENDERING_CUTOUT) && !defined(_SMOOTHNESS_ALBEDO)
	#define SHADOWS_NEED_UV 1//这里 1 直接代表true
#endif

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;
float _AlphaCutoff;

struct VertexData {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float2 uv :TEXCOORD0;
};

struct Interpolators {
	float4 position : SV_POSITION;
	#if SHADOWS_NEED_UV
		float2 uv :TEXCOORD0;
	#endif
	#if defined(SHADOWS_CUBE)
		float3 lightVec : TEXCOORD1;
	#endif
};

float GetAlpha(Interpolators i)
{
	float alpha = _Tint.a;
	#if SHADOWS_NEED_UV
		alpha*=tex2D(_MainTex,i.uv.xy).a;
	#endif
	return alpha;
}

Interpolators MyShadowVertexProgram(VertexData v)
{
	Interpolators i;
	#if defined(SHADOWS_CUBE)
		i.position=UnityObjectToClipPos(v.position);
		i.lightVec=mul(unity_ObjectToWorld,v.positon).xyz-_LightPositionRange.xyz;
	#else
		i.position=UnityClipSpaceShadowCasterPos(v.position.xyz,v.normal);
		i.position=UnityApplyLinearShadowBias(i.position);
	#endif
	#if SHADOWS_NEED_UV
		i.uv=TRANSFORM_TEX(v.uv,_MainTex);
	#endif
	return i;
}

float4 MyShadowFragmentProgram (Interpolators i) : SV_TARGET 
{
	float alpha = GetAlpha(i);
	#if defined(_RENDERING_CUTOUT)
		clip(alpha - _AlphaCutoff);
	#endif

	#if defined(SHADOWS_CUBE)
		float depth = length(i.lightVec) + unity_LightShadowBias.x;
		depth *= _LightPositionRange.w;
		return UnityEncodeCubeShadowDepth(depth);
	#else
		return 0;
	#endif
}


#endif