﻿Shader "HCS/SampleDeferredLight"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" { }
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        Pass
        {
            Tags { "LightMode" = "Deferred" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            struct a2v
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                float3 worldNormal: TEXCOORD1;
                float3 worldPos: TESSFACTOR2;
            };
            
            struct DeferredOutput
            {
                float4 gBuffer0: SV_TARGET0;
                float4 gBuffer1: SV_TARGET1;
                float4 gBuffer2: SV_TARGET2;
                float4 gBuffer3: SV_TARGET3;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            
            v2f vert(a2v v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityWorldToClipPos(o.worldPos);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            DeferredOutput frag(v2f i)
            {
                DeferredOutput o;
                //延迟渲染对不透明的支持不是很好  所以这里没有A
                half3 color = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;
                o.gBuffer0.rgb = color;//基础颜色
                o.gBuffer0.a = 1;//遮挡
                o.gBuffer1.rgb = _Specular;//高光颜色
                o.gBuffer1.a = _Gloss;//高光系数
                o.gBuffer2 = float4(normalize(i.worldNormal), 1);//世界法线
                o.gBuffer3 = half4(color,1);//自发光 ,lightmap , 反射探针 深度缓冲等
                return o;
            }
            
            ENDCG
            
        }
    }
}
