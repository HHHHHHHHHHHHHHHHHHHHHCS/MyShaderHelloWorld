Shader "ObjectEffect/S_StencilMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _StencilRef ("StencilRef", Range(0, 100)) = 1
    }
    SubShader
    {
		Tags { "RenderType" = "Opaque"   "Queue" = "Transparent+1"}

        Pass
        {
            ZTest Always//别忘记开启深度测试
            Stencil
            {
                Ref[_StencilRef]
                Comp equal
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
                return col;
            }
            ENDCG
            
        }

    }
}
