Shader "HCS/S_CartoonHuman"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Diffuse ("Color", Color) = (1, 1, 1, 1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 2)) = 0.1
        _Steps ("Steps", Range(1, 20)) = 1
        _ToonEffect ("ToonEffect", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
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
                float4 vertex: SV_POSITION;
            };
            
            half4 _OutlineColor;
            half _OutlineWidth;
            
            v2f vert(appdata_base v)
            {
                v2f o;
                // v.vertex.xyz += v.normal * _OutlineWidth;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                
                float3 pos = UnityObjectToViewPos(v.vertex);
                float3 normal = normalize(UnityObjectToViewPos(v.normal));
                pos += float4(normal, 0) * _OutlineWidth;
                o.vertex = mul(UNITY_MATRIX_P, float4(pos.xyz,v.vertex.w));
                
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
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                fixed3 normal: NORMAL;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                fixed3 worldNormal: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Diffuse;
            float _Steps;
            float _ToonEffect;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                half4 albedo = tex2D(_MainTex, i.uv);
                
                half3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                
                float diffLight = dot(worldLightDir, i.worldNormal) * 0.5 + 0.5;
                
                float toon = floor(diffLight * _Steps) / _Steps;
                diffLight = lerp(diffLight, toon, _ToonEffect);
                
                half3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * diffLight;
                
                return half4(ambient + diffuse, 1);
            }
            ENDCG
            
        }
    }
}
