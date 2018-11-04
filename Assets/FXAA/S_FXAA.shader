Shader "HCS/s_FXAA"
{
    Properties
    {
		_MainTex("Texture",2D)="white"{}
    }

	CGINCLUDE
	
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;

	struct a2v 
	{
		float4 vertex:POSITION;
		float2 uv :TEXCOORD0;
	};

	struct v2f
	{
		float4 pos :SV_POSITION;
		float2 uv:TEXCOORD0;
	};

	v2f vert(a2v v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv=v.uv;
		return o;
	}

	ENDCG

    SubShader
    {
		Cull off
		ZTest Always
		ZWrite off
		

		Pass
		{// 0 blitPass
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


				float4 frag(v2f i):SV_TARGET
				{
					float4 sample = tex2D(_MainTex,i.uv);
					return sample;
				}
			ENDCG
		}
	}
}
