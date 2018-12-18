Shader "HCS/S_EasyBloom" 
{
	Properties 
	{
		_MainTex("Texture",2D)="white"{}
		_BlurRadius("Blur Radius",Range(1,20))=5
		_BloomFactor("Bloom Factor",Range(0,1))=0.5
		_ColorThreshold("Color Threshold",Color)=(0.5,0.5,0.5,1)


	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }

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
			float2 _MainTex_TexelSize;
			int _BlurRadius;
			float _BloomFactor;
			fixed4 _ColorThreshold;

			v2f vert(appdata_img i)
			{
				v2f o ;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv=i.texcoord;
				return o;
			}

			fixed4 frag(v2f o):SV_TARGET
			{

				float4 col = float4(0,0,0,0);

				for(int y=-_BlurRadius;y<=_BlurRadius;y++)
				{
					for(int x=-_BlurRadius;x<=_BlurRadius;x++)
					{
						float4 tempCol = tex2D(_MainTex,o.uv+float2( _MainTex_TexelSize.x*x,_MainTex_TexelSize.y*y));
						tempCol=saturate(tempCol-_ColorThreshold);
						col+=tempCol;
					}
				}

				int count = _BlurRadius*2+1;
				count*=count;

				col/=count;

				col=tex2D(_MainTex,o.uv)+col*_BloomFactor;

				return col ;
			}
			
			ENDCG
		}
	}
	FallBack off
}
