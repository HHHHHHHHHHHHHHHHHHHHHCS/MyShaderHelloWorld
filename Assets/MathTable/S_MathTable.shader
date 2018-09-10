Shader "HCS/MathTable" 
{
    Properties
    {

    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            

            struct a2v
            {
                float4 vertex:POSITION;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 worldPos:TEXCOORD0;
            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld ,v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(i.worldPos.x,i.worldPos.y,1,1);
            }

            ENDCG
        }

    }
	FallBack "Diffuse"
}