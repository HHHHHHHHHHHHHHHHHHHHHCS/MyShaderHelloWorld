﻿Shader "ScreenEffect/DOF" 
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurTex ("Blur", 2D) = "white"{}
	}
	SubShader 
	{
		pass
		{
			Cull off
			ZTest off
			ZWrite off

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
			sampler2D _CameraDepthTexture;
			float _FocalDistance;
			float _LerpDistance;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				fixed4 ori = tex2D(_MainTex,i.uv);
				fixed4 blur=tex2D(_BlurTex,i.uv);

				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
				depth=Linear01Depth(depth);

				float dis =  depth-_FocalDistance;

				float blurLerp = dis/_LerpDistance;

				fixed4 final=(dis<=0.0)?ori:lerp(ori,blur,clamp( blurLerp,0,1));

				return final;
			}

			ENDCG
		}
	}
	Fallback off
}
