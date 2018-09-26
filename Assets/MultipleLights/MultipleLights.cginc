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

v2f ComputeVertexLightColor (v2f i) 
{
    #if defined(VERTEXLIGHT_ON)
    /*
        float3 lightPos=flaot3(unity_4LightPosX0.x,unity_4LightPosY0.x,unity_4LightPosZ0.x);
        float3 lightVec= lightPos-i.worldPos;
        float3 lightDir=normalize(lightVec);
        float ndotl=DotClamped(i.normal,lightDir);
        float attenuation=1/(1+dot(lightDir,lightDir)) * unity_4LightAtten0.x;
        i.vertexLightColor = unity_LightColor[0].rgb*ndotl*attenuation;
    */
        i.vertexLightColor = Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, i.worldPos, i.normal
                );
    #endif
    return i ;

}

v2f vert(a2v i)
{
    v2f o;
    o.pos=UnityObjectToClipPos(i.vertex);
    o.worldPos = mul(unity_ObjectToWorld,i.vertex);
    o.uv=TRANSFORM_TEX(i.texcoord,_MainTex);
    o.normal= UnityObjectToWorldNormal(i.normal);
    o=ComputeVertexLightColor(o);
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

    //float attenuation = 1/(1+dot(lightVec,lightVec));
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

fixed4 frag(v2f i):SV_TARGET
{
    i.normal = normalize(i.normal);	
    //float3 lightDir = _WorldSpaceLightPos0.xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    //float3 lightColor = _LightColor0.rgb;
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

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