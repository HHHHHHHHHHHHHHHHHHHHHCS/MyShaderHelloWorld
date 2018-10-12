#if !defined(MY_DEFERRED_SHADING)
#define MY_DEFERRED_SHADING

#include "UnityPBSLighting.cginc"

struct a2v
{
	float4 vertex :POSITION;
	float3 normal :NORMAL;
};

struct v2f
{
	float4 pos:SV_POSITION;
	float4 uv :TEXCOORD0;
	float3 ray:TEXCOORD1;
};

UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
sampler2D _CameraGBufferTexture0;
sampler2D _CameraGBufferTexture1;
sampler2D _CameraGBufferTexture2;
float4 _LightColor, _LightDir;

UnityLight CreateLight () 
{
	UnityLight light;
	light.dir = _LightDir;
	light.color = _LightColor.rgb;
	return light;
}

v2f vert(a2v v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv=ComputeScreenPos(o.pos);
	o.ray=v.normal; 
	return o;
}

float4 frag(v2f i):SV_TARGET
{
	float2 uv = i.uv.xy / i.uv.w;

	float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,uv);
	depth=Linear01Depth(depth); 

	float3 rayToFarPlane = i.ray * _ProjectionParams.z / i.ray.z;
	float3 viewPos = rayToFarPlane * depth;
	float3 worldPos = mul(unity_CameraToWorld, float4(viewPos, 1)).xyz;
	float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);



	float3 albedo = tex2D(_CameraGBufferTexture0, uv).rgb;
	float3 specularTint = tex2D(_CameraGBufferTexture1, uv).rgb;
	float3 smoothness = tex2D(_CameraGBufferTexture1, uv).a;
	float3 normal = tex2D(_CameraGBufferTexture2, uv).rgb * 2 - 1;
	float oneMinusReflectivity = 1 - SpecularStrength(specularTint);

	UnityLight light = CreateLight();
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	float4 color = UNITY_BRDF_PBS(
    	albedo, specularTint, oneMinusReflectivity, smoothness,
    	normal, viewDir, light, indirectLight
    );

	light.dir = -_LightDir;

	return color;
}

#endif