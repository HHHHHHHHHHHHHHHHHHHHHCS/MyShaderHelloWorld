Shader "CommonEffect/S_015_SpriteOutline"
{
	Properties
	{
		_MainTex("Base (RGB)",2D)="white"{}
		_Color("Color",Color)=(1,1,1,1)
	}
	SubShader
	{
		Tags{"Queue"="Transparent" "RenderType"="Transparent"}
		Cull Off
		Blend One OneMinusSrcAlpha

		Pass
		{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler _MainTex;
			float4 _MainTex_TexelSize;
			half4 _Color;


			struct v2f
			{
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 c = tex2D(_MainTex,i.uv);
				c.rgb *= c.a;
				half4 outlineC = _Color;
				outlineC.a *= ceil(c.a);
				outlineC.rgb *= outlineC.a;

				half alpha_up = tex2D(_MainTex,i.uv+float2(0,_MainTex_TexelSize.y)).a;
				half alpha_down = tex2D(_MainTex,i.uv-float2(0,_MainTex_TexelSize.y)).a;
				half alpha_right = tex2D(_MainTex,i.uv+float2(_MainTex_TexelSize.x,0)).a;
				half alpha_left = tex2D(_MainTex,i.uv-float2(_MainTex_TexelSize.x,0)).a;

				//return lerp(outlineC,c,alpha_up*alpha_down*alpha_right*alpha_left);
				return lerp(outlineC,c,ceil(alpha_up*alpha_down*alpha_right*alpha_left));
			}

			ENDCG
		}
	}
}
