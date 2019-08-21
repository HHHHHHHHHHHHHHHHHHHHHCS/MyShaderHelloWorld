Shader "HCS/S_SpawnShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }
            
            
            CGPROGRAM
			#pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 pos: SV_POSITION;
                float4 worldPos: TEXCOORD1;
                SHADOW_COORDS(2)
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW(o);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                
                //half shadow = SHADOW_ATTENUATION(i);
                
                //这个函数计算包含了光照衰减已经阴影,因为ForwardBase逐像素光源一般是方向光，衰减为1，atten在这里实际是阴影值
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                return col * atten;
            }
            ENDCG
            
        }
        
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
            #include "UnityCG.cginc"
            
            struct v2f
            {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
            
        }
    }
}
