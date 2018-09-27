#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

struct a2v
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;

    #if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD3;
	#endif
};

uniform fixed4 _Tint;
uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;
uniform float4 _SpecularTint;
uniform float _Metallic;
uniform float _Smoothness;
//uniform sampler2D _HeightMap;
//uniform float4 _HeightMap_TexelSize;
uniform sampler2D _NormalMap;
uniform float _BumpScale;

void ComputeVertexLightColor (inout v2f i) 
{
    #if defined(VERTEXLIGHT_ON)
        i.vertexLightColor = Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, i.worldPos, i.normal
                );
    #endif
}

v2f vert(a2v i)
{
    v2f o;
    o.pos=UnityObjectToClipPos(i.vertex);
    o.worldPos = mul(unity_ObjectToWorld,i.vertex);
    o.uv=TRANSFORM_TEX(i.texcoord,_MainTex);
    o.normal= UnityObjectToWorldNormal(i.normal);
    ComputeVertexLightColor(o);
    return o;
}

UnityLight CreateLight(v2f i)
{
    UnityLight light;

    #if defined(POINT) || defined(POINT_COOKIE)|| defined(SPOT)
        light.dir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif

    UNITY_LIGHT_ATTENUATION(attenuation,0,i.worldPos);
    light.color=_LightColor0.rgb*attenuation;
    light.ndotl=DotClamped(i.normal,light.dir);
    return light;
}

UnityIndirect CreateIndirectLight (v2f i) 
{
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif

    #if defined(FORWARD_BASE_PASS)
		indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
	#endif

    return indirectLight;
}

/*
void InitFragHeight(inout v2f i)
{
	float2 du = float2(_HeightMap_TexelSize.x * 0.5, 0);
	float u1 = tex2D(_HeightMap, i.uv - du);
	float u2 = tex2D(_HeightMap, i.uv + du);
//	float3 tu = float3(1, u2 - u1, 0);

	float2 dv = float2(0, _HeightMap_TexelSize.y * 0.5);
	float v1 = tex2D(_HeightMap, i.uv - dv);
	float v2 = tex2D(_HeightMap, i.uv + dv);
//	float3 tv = float3(0, v2 - v1, 1);

//	i.normal = cross(tv, tu);
	i.normal = float3(u1 - u2, 1, v1 - v2);
	i.normal = normalize(i.normal);
}
*/

void InitializeFragmentNormal(inout v2f i) 
{
	i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
	i.normal.xy *= _BumpScale;
	i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
	i.normal = i.normal.xzy;
	i.normal = normalize(i.normal);
}

fixed4 frag(v2f i):SV_TARGET
{
    //InitFragHeight(i);
	InitializeFragmentNormal(i);

    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

	//albedo*=tex2D(_HeightMap,i.uv);

    float3 specularTint;
    float oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );

    return UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir,
        CreateLight(i), CreateIndirectLight(i)
    );
}		
#endif