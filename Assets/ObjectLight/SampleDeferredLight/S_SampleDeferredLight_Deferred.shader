Shader "HCS/SampleDeferredLight_Deferred"
{
    Properties { }
    SubShader
    {
        ZWrite Off
        Blend One One
        Tags { "RenderType" = "Opaque" }
        
        Pass
        {
            CGPROGRAM
            
            //基本targe支持MRT
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_lightpass
            //代表排除不支持MRT的硬件
            #pragma exclude_renderers norm
            
            #include "UnityCG.cginc"
            #include "UnityDeferredLibrary.cginc"
            #include "UnityGBuffer.cginc"
            
            sampler2D _CameraGBufferTexture0;
            sampler2D _CameraGBufferTexture1;
            sampler2D _CameraGBufferTexture2;
            sampler2D _CameraGBufferTexture3;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            
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
                float2 uv = i.uv.xy / i.uv.w;
                
                //通过深度和方向重新构造世界坐标
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
                depth=Linear01Depth(depth);
                return 0;
            }
            
            ENDCG
            
        }
    }
}
