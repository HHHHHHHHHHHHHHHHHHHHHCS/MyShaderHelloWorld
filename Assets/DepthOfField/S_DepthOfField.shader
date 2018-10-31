Shader "HCS/DepthOfField" 
{
	Properties 
	{
		_MainTex("Texture",2D)="white"{}
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex,_CameraDepthTexture;
		float4 _MainTex_TexelSize;
		float _FocusDistance,_FocusRange;

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
		{// 0 circleOfConfusionPass
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				half frag(v2f i):SV_TARGET
				{
					half depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
					depth=LinearEyeDepth(depth);

					float coc =(depth-_FocusDistance)/_FocusRange;
					coc = clamp(coc, -1, 1);
					return coc;
				}
			ENDCG
		}

		pass
		{// 1 bokenPass
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				half4 frag(v2f i):SV_TARGET
				{
					half3 color = 0;
					int weight = 0;
					for(int u=-4;u<4;u++)
					{
						for(int v=-4;v<=4;v++)
						{
							float2 o = float2(u,v);
							if(length(o)<=4)
							{
								o*=_MainTex_TexelSize.xy*2;
								color +=tex2D(_MainTex ,i.uv+o).rgb;
								weight+=1;
							}
						}
					}
					color *= 1.0/weight;
					return half4(color,1);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
