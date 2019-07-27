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
            
            
            ENDCG
            
        }
    }
}
