Shader "HCS/S_CartoonHouse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Diffuse ("Color", Color) = (1, 1, 1, 1)
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
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                half3 worldNormal: TEXCOORD1;
                half3 worldPos: TEXCOORD2;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            half4 _Diffuse;
            half _Step;
            half _ToonEffect;
            
            half4 frag(v2f i): SV_TARGET
            {
                half4 ambient = UNITY_LIGHTMODEL_AMBIENT;
                
                half4 albedo = tex2D(_MainTex, i.uv);
                
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos).xyz);
                
                half lambert = dot(lightDir, i.worldNormal) * 0.5 + 0.5;
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
