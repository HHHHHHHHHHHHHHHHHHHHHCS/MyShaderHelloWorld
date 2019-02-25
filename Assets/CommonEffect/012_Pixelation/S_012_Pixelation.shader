Shader "CommonEffect/S_012_Pixelation"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white"{}
		_PixelNumberX("Pixel number along x",float) = 500
		_PixelNumberY("Pixel number along y",float) = 500
	}
	SubShader
	{
		Pass
		{
			Tags{"RenderType"="Opaque"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _PixelNumberX;
			float _PixelNumberY;

			struct v2f
			{
				half4 pos:POSITION;
				half2 uv:TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv= TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half ratioX = 1 / _PixelNumberX;
				half ratioY = 1 / _PixelNumberY;
				half2 uv = half2((int)(i.uv.x/ratioX) * ratioX,(int)(i.uv.y/ratioY)*ratioY);
				return tex2D(_MainTex,uv);
			}

			ENDCG

		}
	}
}
