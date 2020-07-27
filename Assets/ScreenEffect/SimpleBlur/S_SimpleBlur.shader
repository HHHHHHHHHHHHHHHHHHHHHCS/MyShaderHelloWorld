Shader "ScreenEffect/S_SamplerBlur" 
{
	Properties 
	{
		_MainTex ("_MainTex", 2D) = "white"{}
		_BlurRadius ("_BlurRadius", Range(1,10)) = 5
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
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			int _BlurRadius;

			v2f vert(appdata_img i)
			{
				v2f o;

				o.pos=UnityObjectToClipPos(i.vertex);
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
						col+= tex2D(_MainTex,o.uv+float2( _MainTex_TexelSize.x*x,_MainTex_TexelSize.y*y));
					}
				}

				int count = _BlurRadius*2+1;
				count*=count;


				return  col/count ;
			}


			ENDCG
		}

	}
	FallBack off
}
