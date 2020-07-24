Shader "ObjectEffect/S_StencilReplace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _StencilRef ("StencilRef", Range(0, 100)) = 1
        _Alpha ("Alpha", Range(0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            
            ZTest Always//别忘记开启深度测试
            Stencil
            {
                Ref[_StencilRef]
                Comp GEqual//大于或者等于
                Pass Replace//成功则写入
            }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Alpha;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                col.a = _Alpha;
                return col;
            }
            ENDCG
            
        }
    }
}
