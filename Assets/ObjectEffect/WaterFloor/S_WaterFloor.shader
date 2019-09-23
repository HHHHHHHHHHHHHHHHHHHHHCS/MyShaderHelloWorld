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
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
