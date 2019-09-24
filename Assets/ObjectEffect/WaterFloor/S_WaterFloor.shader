Shader "Unlit/S_WaterFloor"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Normal ("NormalMap", 2D) = "bump" { }
        _NormalScale ("Normal Scale", Range(0, 5)) = 1
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _WetColor ("Wet Color", Color) = (1, 1, 1, 1)
        _WetMap ("Wet Map", 2D) = "white" { }
        _WetGlossiness ("Wet Smoothness", Range(0, 1)) = 0.5
        _WetMetallic ("Wet Metallic", Range(0, 1)) = 0.0
        _Wetness ("Wetness", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include"UnityStandardUtils.cginc"
            #include"AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                
                float4 vertex: SV_POSITION;
                float2 uv_main: TEXCOORD0;
                float2 uv_wet: TEXCOORD1;
                float2 uv_normal: TEXCOORD2;
                float3 worldPos: TEXCOORD3;
            };
            
            half4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Normal;
            float4 _Normal_ST;
            float _NormalScale;
            float _Glossiness;
            float _Metallic;
            half4 _WetColor;
            sampler2D _WetMap;
            float4 _WetMap_ST;
            float _WetGlossiness;
            float _WetMetallic;
            float _Wetness;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_main = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_wet = TRANSFORM_TEX(v.uv, _WetMap);
                o.uv_normal = TRANSFORM_TEX(v.uv, _Normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                half wetness = tex2D(_WetMap, i.uv_wet).r;
                half4 col = tex2D(_MainTex, i.uv_main) * lerp(_Color, _WetColor, wetness);
                
                half3 normal = lerp(UnpackScaleNormal(tex2D(_Normal, i.uv_normal), _NormalScale), half3(0, 0, 1), wetness);
                
                half metallic = lerp(_Metallic, _WetMetallic, wetness);
                half smoothness = lerp(_Glossiness, _WetGlossiness, wetness);
                
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldNormal = ((normal));
                
                fixed3 albedo = col;
                
                half3 specColor;
                half oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(albedo, metallic, specColor, oneMinusReflectivity);
                
                UnityLight DirectLight;
                DirectLight.dir = worldLightDir;
                DirectLight.color = _LightColor0.xyz;
                DirectLight.ndotl = DotClamped(worldNormal, worldLightDir);
                
                UnityIndirect InDirectLight;
                InDirectLight.diffuse = 1;
                InDirectLight.specular = 0;
                
                return UNITY_BRDF_PBS(albedo, specColor, oneMinusReflectivity,
                smoothness, worldNormal, worldViewDir,
                DirectLight, InDirectLight);
            }
            ENDCG
            
        }
    }
}
