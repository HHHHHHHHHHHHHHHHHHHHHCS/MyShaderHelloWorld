Shader "HCS/DepthOfField" 
{
	Properties 
	{
		_MainTex("Texture",2D)="white"{}
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _Maintex_TexelSize;

		struct a2v
		{
			float4 vertex :POSITION;
			float2 uv :TEXCOORD0;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv :TEXCOORD0;
		};

		v2f vert (a2v i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv=i.uv;
			return o;
		}


	ENDCG

	SubShader 
	{
		Cull off
		ZTest Always
		ZWrite off

		pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				half4 frag(v2f i):SV_TARGET
				{
					return tex2D(_MainTex,i.uv);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
