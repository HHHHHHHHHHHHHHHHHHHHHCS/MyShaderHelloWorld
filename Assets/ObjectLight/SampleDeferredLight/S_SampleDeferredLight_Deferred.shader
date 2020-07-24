Shader "ObjectLight/SampleDeferredLight_Deferred"
{
    Properties { }
    SubShader
    {
        Pass
        {
            ZWrite Off
            //LDR:Blend DstColor Zero    HDR:Blend One One
            Blend [_SrcBlend] [_DstBlend]
            
            CGPROGRAM
            
            //基本targe支持MRT
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_lightpass
            //代表排除不支持MRT的硬件
            #pragma exclude_renderers nomrt
            #pragma multi_compile _ UNITY_HDR_ON
            
            #include "UnityCG.cginc"
            #include "UnityDeferredLibrary.cginc"
            #include "UnityGBuffer.cginc"
            
            sampler2D _CameraGBufferTexture0;
            sampler2D _CameraGBufferTexture1;
            sampler2D _CameraGBufferTexture2;
            //_CameraGBufferTexture3 是Unity 自己给的 不用加
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            
            //unity_v2f_deferred 也是这个结构体
            struct v2f
            {
                float4 pos: SV_POSITION;
                float4 uv: TEXCOORD0;
                float3 ray: TEXCOORD1;
            };
            
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = ComputeScreenPos(o.pos);
                o.ray = UnityObjectToViewPos(i.vertex) * float3(-1, -1, 1);
                //如果绘制的是全屏的Quad 则返回0 否则返回1
                o.ray = lerp(o.ray, i.normal, _LightAsQuad);
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                //UnityDeferredLibrary.cginc -> UnityDeferredCalculateLightParams() 可以代替下面开始...结束的这个函数
                /**/
                float3 worldPos;
                float2 uv;
                half3 lightDir;
                float atten;
                float fadeDist;
                UnityDeferredCalculateLightParams(i, worldPos, uv, lightDir, atten, fadeDist);
                /**/
                /*
                //############开始
                float2 uv = i.uv.xy / i.uv.w;
                //通过深度和方向重新构造世界坐标
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
                depth = Linear01Depth(depth);
                //ray只能代表方向 不能代表长度 _ProjectionParams.z 是远平面的距离  然后 xyz是等比例缩放 远平面距离/等比例的z 的长度方向
                float3 rayToFraPlan = i.ray * (_ProjectionParams.z / i.ray.z);
                float4 viewPos = float4(rayToFraPlan * depth, 1);
                float3 worldPos = mul(unity_CameraToWorld, viewPos).xyz;
                
                //和阴影的Distance进行计算 如果过远则舍弃
                float fadeDist = UnityComputeShadowFadeDistance(worldPos, viewPos.z);
                
                #if defined(SPOT)
                    float3 toLight = _LightPos.xyz - worldPos;
                    half3 lightDir = normal(toLight);
                    float4 uvCookie = mul(unity_WorldToLight, float4(worldPos, 1));
                    float atten = tex2DBias(_LightTexture0, float4(uvCookie.xy / uvCookie.w, 0, -8)).w;
                    
                    atan *= uvCookie < 0;
                    
                    atten *= tex2D(_LightTextureB0, dot(toLight, toLight) * _LightPos.w).r;
                    
                    atten *= UnityDeferredComputeShadow(worldPos, fadeDist, uv);
                    
                #elif defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                    half3 lightDir = -_LightDir.xyz;
                    float atten = 1.0;
                    
                    atten *= UnityDeferredComputeShadow(worldPos, fadeDist, uv);
                    
                    #if defined(DIRECTIONAL_COOKIE)
                        float4 uvCookie = mul(unity_WorldToLight, float4(worldPos, 1));
                        //这里是方向光不是透视的  所以不用除以W
                        atten *= tex2Dbias(_LightTextureB0, float4(uvCookie.xy, 0, -8)).w;
                    #endif
                #elif defined(POINT) || defined(POINT_COOKIE)
                    float3 toLight = _LightPos.xyz - worldPos;
                    half3 lightDir = normalize(toLight);;
                    
                    float atten = tex2D(_LightTextureB0, dot(toLight, toLight) * _LightPos.w).r;
                    
                    atten *= UnityDeferredComputeShadow(worldPos, fadeDist, uv);
                    
                    #if defined(POINT_COOKIE)
                        float4 uvCookie = mul(unity_WorldToLight, float4(worldPos, 1));
                        atten *= texCUBEbias(_LightTextureB0, float4(uvCookie.xyz, -8)).w;
                    #endif
                    
                #else
                    half3 lightDir = 0;
                    float atten = 0;
                    
                #endif
                //############结束
                */
                
                half3 lightColor = _LightColor.rgb * atten;
                half4 gbuffer0 = tex2D(_CameraGBufferTexture0, uv);
                half4 gbuffer1 = tex2D(_CameraGBufferTexture1, uv);
                half4 gbuffer2 = tex2D(_CameraGBufferTexture2, uv);
                
                half3 diffuseColor = gbuffer0.rgb;
                half3 specularColor = gbuffer1.rgb;
                float gloss = gbuffer1.a * 255;
                float3 worldNormal = normalize(gbuffer2.xyz * 2 - 1);
                
                half3 viewDir = UnityWorldSpaceViewDir(worldPos);
                half3 halfDir = normalize(lightDir + viewDir);
                
                half3 diffuse = lightColor * diffuseColor * max(0, dot(worldNormal, lightDir));
                half3 specular = lightColor * specularColor * pow(max(0, dot(worldNormal, halfDir)), gloss);
                
                half4 col = half4(diffuse + specular, 1);
                
                #ifdef UNITY_HDR_ON
                    return col;
                #else
                    return exp2(-col);
                #endif
            }
            
            ENDCG
            
        }
        
        Pass
        {
            //理论上一个通道就够了 第二个通道处理LDR
            //转码Pass 针对LDR的转码处理
            
            ZTest Always
            Cull Off
            ZWrite Off
            
            Stencil
            {
                ref[_StencilNonBackground]
                readMask[_StecilNonBackground]
                
                compback equal
                compfront equal
            }
            
            CGPROGRAM
            
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma exclude_renderers nomrt
            
            #include "UnityCG.cginc"
            
            sampler2D _LightBuffer;
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 texcoord: TEXCOORD0;
            };
            
            v2f vert(float4 vertex: POSITION, float2 texcoord: TEXCOORD0)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(vertex);
                o.texcoord = texcoord;
                //单通道立体渲染，目前主要用于VR
                #ifdef UNITY_SINGLE_PASS_STEREO
                    //unity_StereoScaleOffset一个长度为2的数组，代表两个眼睛的一些偏移值等，还是用在VR立体渲染中的
                    o.texoord = TransformStereoScreenSpaceTex(o.texcoord, 1.0);
                #endif
                return o;
            }
            
            half4 frag(v2f i): SV_TARGET
            {
                return - log2(tex2D(_LightBuffer, i.texcoord));
            }
            
            
            ENDCG
            
        }
    }
}
