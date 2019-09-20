Shader "HCS/S_HDWater"
{
    Properties
    {
        _WaterShallowColor ("Water Shallow Color", Color) = (1, 1, 1, 1)
        _WaterDeepColor ("Water Deep Color", Color) = (1, 1, 1, 1)
        _TransAmount ("Water Transparent", Range(0, 10)) = 1
        _DepthRange ("Depth Range", Range(0.001, 10)) = 1
        _NormalTex ("Normal Texture", 2D) = "white" { }
        _WaterSpeed ("Water Speed", Range(0, 20)) = 5
        _Refract ("Refract", Range(0, 5)) = 0.5
        _Gloss ("Gloss", Range(0, 10)) = 5
        _Specular ("Specular", Range(0, 8)) = 1
        _SpecularColor ("SpecularColor", Color) = (1, 1, 1, 1)
        _WaveTex ("Wave Texure", 2D) = "white" { }
        _NoiseTex ("Noise Texure", 2D) = "white" { }
        _WaveSpeed ("Wave Speed", float) = 1
        _WaveRange ("Wave Range", float) = 0.5
        _WaveRangeA ("WaveRangeA", float) = 1
        _WaveDelta ("WaveDelta", float) = 0.5
        _Distortion ("Distortion", float) = 10
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100
        
        GrabPass
        {
            "_GrabPass"
        }
        
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
                float2 uv_noise: TEXCOORD3;
            };
            
            half4 _WaterShallowColor, _WaterDeepColor;
            half _TransAmount, _DepthRange;
            sampler2D_float _CameraDepthTexture;
            sampler2D _NormalTex;
            float4 _NormalTex_ST;
            float _WaterSpeed;
            float _Refract;
            float _Gloss;
            float _Specular;
            half4 _SpecularColor;
            sampler2D _WaveTex;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _WaveSpeed;
            float _WaveRange;
            float _WaveRangeA;
            float _WaveDelta;
            sampler2D _GrabPass;
            float4 _GrabPass_TexelSize;
            float _Distortion;
            
            
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.scrPos.z);//计算顶点深度 这时候在[NearClip,FarClip]内
                o.wpos = mul(unity_ObjectToWorld, o.vertex);
                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalTex);
                o.uv_noise = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }
            
            half3 CalcBlinnPhong(half3 col, half3 normal, half3 wpos)
            {
                float3 N = normalize(normal);
                float3 L = normalize(-UnityWorldSpaceLightDir(wpos));
                float3 V = UnityWorldSpaceViewDir(wpos) ;
                V.xy += V.z * normal.xy;
                V = normalize(V);
                
                
                float3 H = normalize(L + V) ;
                
                half3 ambient = col * unity_AmbientSky;
                
                //float NoH = max(dot(N, L), 0) / 2 + 0.5 ;
                float NOL = max(dot(N, L), 0);
                half3 diffuse = col * _LightColor0 * NOL;
                
                float PowNoH = pow(max(dot(N, H), 0), _Specular);
                half3 specular = _SpecularColor * _LightColor0 * PowNoH * _Gloss;
                
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
                float2 offset = UnityObjectToWorldNormal(normal).xy * _Refract;
                bump1 = tex2D(_NormalTex, i.uv_normal + offset +float2(_WaterSpeed * frac(_Time.x), 0));
                bump2 = tex2D(_NormalTex, float2(1 - i.uv_normal.y, i.uv_normal.x) + offset +float2(_WaterSpeed * frac(_Time.x), 0));
                normal = UnpackNormal((bump1 + bump2) * 0.5);
                
                //波浪
                half waveA = 1 - min(_WaveRangeA, deltaDepth) / _WaveRangeA;
                half4 noiserColor = tex2D(_NoiseTex, i.uv_noise);
                half4 waveColor = tex2D(_WaveTex, float2(waveA + _WaveRange * sin(_Time.x * _WaveSpeed + noiserColor.r), 1) + offset);
                half4 waveColor2 = tex2D(_WaveTex, float2(waveA + _WaveRange * sin(_Time.x * _WaveSpeed + _WaveDelta + noiserColor.r), 1) + offset);
                
                //抓屏
                float2 gOffset = normal.xy * _Distortion * _GrabPass_TexelSize.xy;
                i.scrPos.xy = gOffset * i.scrPos.z + i.scrPos.xy;
                half3 reflCol = tex2D(_GrabPass, i.scrPos.xy / i.scrPos.w);
                
                
                half4 col = lerp(_WaterShallowColor, _WaterDeepColor, saturate(min(deltaDepth, _DepthRange) / _DepthRange));
                col.rgb = CalcBlinnPhong(col.rgb, normal, i.wpos);
                //col.rgb += (waveColor.rgb + waveColor2.rgb) * waveA ;
                //col.rgb *= reflCol;
                col.a = min(_TransAmount, deltaDepth) / _TransAmount ;
                
                return col;
            }
            ENDCG
            
        }
    }
}
