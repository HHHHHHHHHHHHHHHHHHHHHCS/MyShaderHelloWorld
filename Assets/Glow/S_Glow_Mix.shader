Shader "HCS/Glow_Mix" 
{
	Properties 
	{
		_MainTex("Texture",2D) = "white"{}
		_BlurTex("Blur Texture",2D) = "white"{}
		_MixValue("Mix Value",Range(0,1))=0.5
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

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BlurTex;
			float4 _Blur_ST;

			float _MixValue;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				fixed4 col = tex2D(_MainTex,i.uv);
				fixed4 blur = tex2D(_BlurTex,i.uv);
				fixed4 final = blur*_MixValue;

				return final;
			}

			ENDCG
		}

	}
	FallBack "Diffuse"
}
