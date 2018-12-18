Shader "HCS/FakingLinquid" 
{
    Properties
    {
		_Color("Color",Color)=(1,1,1,1)
		_MainTex("Albedo (RGB)",2D)="white"{}
		[NoScaleOffset] _FlowMap("Flow Map(RG)",2D)="black"{}
		[NoScaleOffset] _NormalMap("Normal Map",2D)="black"{}
		_UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
		_VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25
		
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        pass
        {
            CGPROGRAM

			#include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            

            struct a2v
            {
                float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 worldPos:TEXCOORD0;
				float2 uv:TEXCOORD1;
            };

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FlowMap;
			sampler2D _NormalMap;
			float _UJump, _VJump;


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld ,v.vertex);
				o.uv=v.texcoord;
                return o;
            }

			float3 FlowUVW(float2 uv,float2 flowVector,float2 jump , float time,bool isFlowB)
			{
				float phaseOffset = isFlowB ? 0.5 : 0;
				float progress = frac(time + phaseOffset);
				float3 uvw;
				uvw.xy = uv - flowVector * progress + phaseOffset;
				uvw.xy += (time - progress) * jump;
				uvw.z = 1 - abs(1 - 2 * progress);
				return uvw;
			}

            fixed4 frag(v2f i):SV_TARGET
            {
				float2 jump = float2(_UJump, _VJump);
				float3 noise =tex2D(_FlowMap, i.uv).rgb;
				float time = _Time.y + noise.r;
				float progress =frac(time);

				float2 uv=noise.rg*2-1;

				float mainUV =TRANSFORM_TEX(i.uv,_MainTex);

				float3 uvwA = FlowUVW(mainUV, uv,jump, time, false);
				float3 uvwB = FlowUVW(mainUV, uv,jump, time, true);

				float3 normalA = UnpackNormal(tex2D(_NormalMap, uvwA.xy)) * uvwA.z;
				float3 normalB = UnpackNormal(tex2D(_NormalMap, uvwB.xy)) * uvwB.z;
				float3 blendNormal =  normalize(normalA + normalB);

				fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
				fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

				fixed4 norA = tex2D(_MainTex, blendNormal.xy) * blendNormal.z;
				fixed4 norB = tex2D(_MainTex, blendNormal.xy) * blendNormal.z;

				fixed4 c = (texA + texB)*(norA+norB) * _Color;

                return c;
            }

            ENDCG
        }

    }
	FallBack "Diffuse"
}