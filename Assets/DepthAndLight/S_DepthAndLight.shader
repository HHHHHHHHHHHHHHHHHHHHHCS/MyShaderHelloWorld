Shader "HCS/S_DepthAndLight"
{
    Properties
    {
		_MainTex("Texture",2D)="white"{}
    }

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex,_CameraDepthTexture;

		struct a2v
		{
			float4 vertex:POSITION;
			float2 uv:TEXCOORD;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		
		v2f vert(a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;

			return o;
		}

	ENDCG

    SubShader
    {
		Cull off
		ZTest Always
		ZWrite off

		pass
		{// 0 depth 
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			fixed4 frag(v2f i):SV_TARGET
			{
				half depth = tex2D(_CameraDepthTexture,i.uv);
				depth=Linear01Depth(depth);
				return depth;
			}

			ENDCG
		}

		pass
		{// 1 light 
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			float4 frag(v2f i):SV_TARGET
			{
				float4 sample = tex2D(_MainTex, i.uv);
				sample.rgb = saturate(sample.rgb);
				sample.a = LinearRgbToLuminance(sample.rgb);
				return sample.a;
			}

			ENDCG
		}
	}
}
