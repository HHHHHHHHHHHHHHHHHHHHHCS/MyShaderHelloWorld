Shader "HCS/S_CartoonHouse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Diffuse ("Color", Color) = (1, 1, 1, 1)
        _BumpMap ("Bump Map", 2D) = "white" { }
        _BumpScale ("Bump Scale", float) = 1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineWidth ("Outline", Range(0, 0.2)) = 0.1
        _Step ("Step", Range(1, 30)) = 3
        _ToonEffect ("Toon Effect", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        //这个外轮廓不是很好
        //UsePass "HCS/S_CartoonHuman/Outline"//新版本2018+ 不用全部大写
        
        
        Pass
        {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f
            {
                float4 pos: SV_POSITION;
            };
            
            half4 _OutlineColor;
            half _OutlineWidth;
            
            v2f vert(appdata_base v)
            {
                //v2f o;
                //v.vertex.xyz += v.normal * _OutlineWidth;
                //o.pos = UnityObjectToClipPos(v.vertex);
                
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_MV, v.vertex);
                normal.x *= UNITY_MATRIX_P[0][0];
                normal.y *= UNITY_MATRIX_P[1][1];
                o.pos.xy += normal.xy * _OutlineWidth;
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                return _OutlineColor;
            }
            
            
            ENDCG
            
        }
        
        
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            struct a2v
            {
                float4 vertex: POSITION;
                half3 normal: NORMAL;
                half4 tangent: tangent;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float4 uv: TEXCOORD0;
                float4 TtoW0: TEXCOORD1;
                float4 TtoW1: TEXCOORD2;
                float4 TtoW2: TEXCOORD3;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                
                o.TtoW0 = float4(worldNormal.x, worldTangent.x, worldBinormal.x, worldPos.x);
                o.TtoW1 = float4(worldNormal.y, worldTangent.y, worldBinormal.y, worldPos.y);
                o.TtoW2 = float4(worldNormal.z, worldTangent.z, worldBinormal.z, worldPos.z);
                return o;
            }
            
            half4 _Diffuse;
            half _Step;
            half _ToonEffect;
            
            half4 frag(v2f i): SV_TARGET
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                
                
                half4 ambient = UNITY_LIGHTMODEL_AMBIENT;
                
                half4 albedo = tex2D(_MainTex, i.uv.xy);
                
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos).xyz);
                
                half4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                half3 tangentNormal = UnpackNormal(packedNormal).rgb;
                half3 normal = normalize(half3(dot(i.TtoW0.xyz, tangentNormal), dot(i.TtoW1.xyz, tangentNormal), dot(i.TtoW2.xyz, tangentNormal)));
                
                half lambert = dot(lightDir, normal) * 0.5 + 0.5;
                lambert = smoothstep(0, 1, lambert);
                float toon = floor(lambert * _Step) / _Step;
                lambert = lerp(lambert, toon, _ToonEffect);
                
                half4 diffuse = albedo * _Diffuse * _LightColor0.rgba * lambert ;
                
                return  ambient + diffuse ;
            }
            
            ENDCG
            
        }
    }
}
