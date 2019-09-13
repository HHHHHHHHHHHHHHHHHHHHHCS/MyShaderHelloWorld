﻿Shader "Unlit/S_HDWater"
{
    Properties
    {
        _WaterShallowColor ("Water Shallow Color", Color) = (1, 1, 1, 1)
        _WaterDeepColor ("Water Deep Color", Color) = (1, 1, 1, 1)
        _TransAmount ("Water Transparent", Range(0, 1)) = 0.5
        _DepthRange ("Depth Range", Range(0.001, 1)) = 0.8
        _NormalTex ("Normal Texture", 2D) = "white" { }
        _WaterSpeed ("Water Speed", Range(0, 20)) = 5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float4 scrPos: TEXCOORD0;
                float3 wpos: TEXCOORD1;
                float2 uv_normal: TEXCOORD2;
            };
            
            half4 _WaterShallowColor, _WaterDeepColor;
            half _TransAmount, _DepthRange;
            sampler2D_float _CameraDepthTexture;
            sampler2D _NormalTex;
            float4 _NormalTex_ST;
            
            float _WaterSpeed;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.scrPos.z);//计算顶点深度 这时候在[NearClip,FarClip]内
                o.wpos = mul(unity_ObjectToWorld, o.vertex);
                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalTex);
                return o;
            }
            
            half3 CalcBlinnPhong(half3 col, half3 normal, half3 wpos)
            {
                float3 N = normalize(normal);
                float3 L = normalize(-UnityWorldSpaceLightDir(wpos));
                float3 V = normalize(UnityWorldSpaceViewDir(wpos));
                
                float3 H = normalize(L + V) ;
                
                half3 ambient = col * UNITY_LIGHTMODEL_AMBIENT;
                
                float NoH = max(dot(N, L), 0) / 2 + 0.5 ;
                half3 diffuse = col * _LightColor0 * NoH;
                
                float PowHoN = pow(max(dot(H, N), 0), 8);
                half3 specular = _LightColor0 * PowHoN;
                
                return ambient + diffuse + specular;
            }
            
            half4 frag(v2f i): SV_Target
            {
                //这个深度 是深度图中的
                float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;//深度值[0,1]
                //也可以用下面这个Unity define的方法  原理一样
                //SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos))
                //下面的UV要手动除以i.srcPos.w 才可以 达到类似的效果
                //SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrPos/i.srcPos.w)
                depth = LinearEyeDepth(depth);//深度根据相机的裁剪范围的值[NearClip,FarClip],是将经过透视投影变换 的深度值还原到NearClip FarClip
                
                //depth = Linear01Depth(depth); //把[NearClip,FarClip]映射到[0,1]
                
                //实际差的深度 = 深度图深度-物体深度
                float deltaDepth = depth - i.scrPos.z ;
                
                half4 bump1 = tex2D(_NormalTex, i.uv_normal + float2(_WaterSpeed * frac(_Time.x), 0));
                half4 bump2 = tex2D(_NormalTex, float2(1 - i.uv_normal.y, i.uv_normal.x) + float2(_WaterSpeed * frac(_Time.x), 0));
                half3 normal = UnpackNormal((bump1 + bump2) * 0.5);
                normal = UnityObjectToWorldNormal(normal);
                
                half4 col = lerp(_WaterShallowColor, _WaterDeepColor, saturate(min(deltaDepth, _DepthRange) / _DepthRange));
                col.rgb = CalcBlinnPhong(col.rgb, normal, i.wpos);
                //col.a = _TransAmount;
                return col;
            }
            ENDCG
            
        }
    }
}
