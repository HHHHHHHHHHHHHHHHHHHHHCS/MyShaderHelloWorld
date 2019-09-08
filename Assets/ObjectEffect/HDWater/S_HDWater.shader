Shader "Unlit/S_HDWater"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
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
            
            struct appdata
            {
                float4 vertex: POSITION;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float4 scrPos: TEXCOORD0;
            };
            
            half4 _Color;
            sampler2D_float _CameraDepthTexture;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.scrPos.z);//计算顶点深度
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;//深度值[0,1]
                //depth = Linear01Depth(depth); //把[near,far]映射到[0,1]
                //depth = LinearEyeDepth(depth);//深度根据相机的裁剪范围的值[0.3,1000],是将经过透视投影变换的深度值还原了
                return half4(depth, depth, depth, 1);
            }
            ENDCG
            
        }
    }
}
