//rawImage特效用
Shader "UI/S_UICapturedImage"
{
    Properties
    {
		[PerRendererData] _MainTex("Main Texture",2D)="white"{}
    }
    SubShader
    {
		Pass
		{
			Name "EFFECT_BASE"

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#pragma shader_feature _ GRAYSCALE SEPIA NEGA PIXEL
			#pragma shader_feature _ ADD SUBTRACT FILL

			#include "UnityCG.cginc"
			#include "UIEffectBase.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			uniform half4 _EffectFactor;
			uniform half4 _ColorFactor;

			v2f_img vert(appdata_img v)
			{
				v2f_img o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				#if UNITY_UV_STARTS_AT_TOP
					o.uv.y=1-o.uv.y;
				#endif
				return o;
			}

			half4 frag(v2f_img i):SV_Target
			{
				half effectFactor = _EffectFactor.x;
				half4 colorFactor = _ColorFactor;

				#if PIXEL
				half2 pixelScale = max(2,(1-effectFactor)*_MainTex_TexelSize.zw);
				i.uv=round(i.uv*pixelScale)/pixelScale;
				#endif

				half4 color = tex2D(_MainTex,i.uv);

				#if defined(UI_TONE)
					color = ApplyToneEffect(color,effectFactor);
				#endif

				#if defined(UI_COLOR)
					color = ApplyColorEffect(color,colorFactor);
				#endif

				color.a = 1;
				return color;
			}
			ENDCG
		}

		Pass
		{
			Name "EFFECT_BLUR"

			CGPROGRAM

			#pragma vertex vert_img
			#pragma fragment frag_blur
			#pragma target 2.0

			#pragma shader_feature _ FASTBLUR MEDIUMBLUR DETAILBLUR

			#include "UnityCG.cginc"
			#include "UIEffectBase.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			uniform half4 _EffectFactor;

			half4 frag_blur(v2f_img i):SV_TARGET
			{
				half2 blurFactor = _EffectFactor.xy;
				half4 color = Tex2DBlurring1D(_MainTex,i.uv,blurFactor*_MainTex_TexelSize.xy*2);
				color.a =1;
				return color;
			}

			ENDCG
		}
    }
}
