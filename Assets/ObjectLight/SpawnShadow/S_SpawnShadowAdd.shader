Shader "ObjectLight/S_SpawnShadowAdd"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 0, 0, 1)
        _Gloss ("Gloss", float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue"="Geometry" "IgnoreProjector" = "True"}


        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            
            half4 _Color;
            
            
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
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                half3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                
                return half4(diffuse, 1.0);
            }
            
            ENDCG
            
        }
        
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            
            Blend One One
            
            CGPROGRAM
            
            #pragma multi_compile_fwdadd_fullshadows
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            half4 _Color;
            half4 _Specular;
            float _Gloss;
            
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
                LIGHTING_COORDS(2, 3) //包含光照阴影衰减
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //计算灯光空间位置和阴影空间位置
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                half3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = saturate(_LightColor0.rgb + _Specular.rgb * pow(max(0, dot(viewDir, halfDir)), _Gloss));
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                return half4((diffuse + specular) * atten, 1.0);
            }
            
            ENDCG
            
        }
    }
}
