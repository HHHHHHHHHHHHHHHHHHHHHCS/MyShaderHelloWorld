Shader "ObjectEffect/TexturedWithDetail"
{
	Properties
	{
		_MainTex ("Splat Map", 2D) = "white" {}
		[NoScaleOffset] _Texture1 ("Texture 1",2D)="white"{}
		[NoScaleOffset] _Texture2 ("Texture 2",2D)="white"{}
		[NoScaleOffset] _Texture3 ("Texture 3", 2D) = "white" {}
		[NoScaleOffset] _Texture4 ("Texture 4", 2D) = "white" {}
	}

	SubShader
	{
		pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
			};

			uniform fixed4 _Tint;
			uniform sampler2D _MainTex,_Texture1,_Texture2,_Texture3,_Texture4;
			uniform float4 _MainTex_ST;

			v2f vert(a2v i)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(i.vertex);
				o.uv=TRANSFORM_TEX(i.texcoord,_MainTex);
				o.uvSplat = i.texcoord;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				fixed4 splat  = tex2D(_MainTex,i.uvSplat);
				fixed4 color = tex2D(_Texture1, i.uv)*splat.r
				+ tex2D(_Texture2, i.uv)*splat.g
				+ tex2D(_Texture3, i.uv)*splat.b
				+ tex2D(_Texture4, i.uv)*(1-splat.r-splat.g-splat.b);
				return color;//*unity_ColorSpaceDouble
			}
			

			ENDCG
		}
	}
}