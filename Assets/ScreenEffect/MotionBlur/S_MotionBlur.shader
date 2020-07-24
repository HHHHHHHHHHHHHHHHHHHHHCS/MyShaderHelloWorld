Shader "ScreenEffect/MotionBlur" 
{
	Properties 
	{
		_MainTex("Base (RGB)",2D)="white"{}
		_BlurAmount("Blur Amount",float)=1.0		
	}
	SubShader 
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		fixed _BlurAmount;

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
		};

		v2f vert(appdata_img v)
		{
			v2f o;

			o.pos=UnityObjectToClipPos(v.vertex);

			o.uv=v.texcoord;

			return o;
		}
		
		fixed4 fragRGB(v2f i):SV_TARGET
		{
			return fixed4(tex2D(_MainTex,i.uv).rgb,_BlurAmount);
		}

		half4 fragA(v2f i):SV_TARGET
		{
			return tex2D(_MainTex,i.uv);
		}

		ENDCG

		ZTest Always Cull off ZWrite off

		pass
		{
			Blend SrcAlpha  OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragRGB

			ENDCG
		}

		pass
		{
			Blend One Zero
			ColorMask A

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragA

			ENDCG
		}

	}
	Fallback off
}
