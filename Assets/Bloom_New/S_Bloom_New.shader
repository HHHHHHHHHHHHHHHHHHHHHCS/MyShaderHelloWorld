Shader "HCS/S_Bloom_New" 
{
	Properties 
	{
		_MainTex("Texture",2D)="white"{}
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;

		struct a2v
		{
			float4 vertex :POSITION;
			float2 uv :TEXCOORD0;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		v2f vert(a2v i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.uv;
			return o;
		}

	ENDCG	

	SubShader 
	{
		Cull Off
		ZTest Always
		ZWrite Off

		pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				half4 frag(v2f v):SV_TARGET
				{
					return tex2D(_MainTex,v.uv)*half4(1,0,0,0);
				}
			ENDCG
		}
	}
}
