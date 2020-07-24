Shader "ObjectLight/S_ForwardLight"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Spcular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                half4 normal: NORMAL;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                half3 vertexLight: TEXCOORD2;
            };
            
            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1));
                
                #ifdef LIGHTMAP_OFF
                    half3 shLight = ShadeSH9(half4(o.worldNormal, 1));
                    o.vertexLight = shLight;
                    #ifdef VERTEXLIGHT_ON
                        float3 vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, o.worldPos, o.worldNormal);
                        o.vertexLight += vertexLight;
                    #endif
                #endif
                
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                half3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
                
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                half3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                
                return half4(ambient + (diffuse + specular) + i.vertexLight, 1);
            }
            ENDCG
            
        }
        
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            
            CGPROGRAM
            
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                LIGHTING_COORDS(2, 3) //AUTOLIGHT.cginc
            };
            
            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            
            v2f vert(a2v v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1));
                
                //计算阴影和光照衰减
                TRANSFER_VERTEX_TO_FRAGMENT(o);//AutoLight.cginc
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                half3 diffuse = _LightColor0.rgb * _Diffuse * max(0, dot(worldNormal, worldLightDir));
                
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(viewDir, halfDir)), _Gloss);
                
                half atten = LIGHT_ATTENUATION(i);
                
                return half4(diffuse + specular * atten, 1.0);
            }
            
            ENDCG
            
        }
    }
}
