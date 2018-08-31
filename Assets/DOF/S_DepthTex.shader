Shader "HCS/DepthTex" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader 
	{
		Tags{"RenderType"="Opaque"}

		pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv:TEXCOORD0;
				float4 pos:SV_POSITION;
			};


			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex); 
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
				depth=Linear01Depth(depth);
				return float4(depth,depth,depth,1);
			}

			ENDCG
		}
	}
	FallBack off
}
