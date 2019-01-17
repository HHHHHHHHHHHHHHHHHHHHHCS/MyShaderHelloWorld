//UI过渡用
Shader "UI/S_UITransition"
{
	Properties
	{
		[PerRendererData] _MainTex("Main Texture",2D)="white"{}
		_Color("Tint",Color) = (1,1,1,1)

		_StencilComp("Stencil Comparison",Float)=8
		_Stencil("Stencil ID",Float)=0
		_StencilOp("Stencil Operation",Float)=0
		_StencilWriteMask("Stencil Write Mask",Float)=255
		_StenCilReadMask("Stencil Read Mask",Float)=255

		_ColorMask("Color Mask",Float)=15

		[Toggle(UNITY_UI_ALPHACLIP)]_UseUIAlphaClip("Use Alpha Clip",Float)=0

		[Header(Transition)]//括号内即为头标题的显示文字 不要加引号,不支持中文
		_TransitionTexture("Transition Texture (A)",2D)="white"{}
		_ParamTex("Parameter Texture",2D)="white"{}
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_SteenCilOp]
			ReadMask[_StenCilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUITestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]


		Pass
		{
			Name "UITRANSITION_DEFAULT"

			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 3.0

				#pragma multi_compile _ UNITY_UI_ALPHACLIP

				#pragma shader_feature _ FADE CUTOFF DISSOLVE

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"
				#include "UIEffectBase.cginc"

				struct a2v
				{
					float4 vertex :POSITION;
					float4 color :COLOR;
					float2 texcoord:TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex:SV_POSITION;
					half4 color:COLOR;
					float2 texcoord:TEXCOORD0;
					float4 wpos:TEXCOORD1;
					half3 param :TEXCOORD2;

					UNITY_VERTEX_OUTPUT_STEREO
				};

				half4 _TextureSampleAdd;//Unity管理:图片格式用Alpha8
				float4 _ClipRect;//Unity管理:2D裁剪用
				half4 _Color;
				sampler2D _MainTex;
				sampler2D _ParamTex;
				sampler2D _TransitionTexture;

				v2f vert(a2v v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					o.wpos = v.vertex;
					o.vertex = UnityObjectToClipPos(v.vertex);

					o.texcoord = UnpackToVec2(v.texcoord.x);//原来的UV
					o.param = UnpackToVec3(v.texcoord.y);//特效区域UV,特效索引

					o.color = v.color * _Color;

					return o;
				}

				half4 frag(v2f i):SV_TARGET
				{
					fixed4 param1 = tex2D(_ParamTex,float2(0.25,i.param.z));
					fixed effectFactor = param1.x;
					float alpha = tex2D(_TransitionTexture,i.param.xy).a;

					half4 color = tex2D(_MainTex,i.texcoord)+_TextureSampleAdd;
					color.a*=UnityGet2DClipping(i.wpos.xy,_ClipRect);

					#if FADE//单纯用噪音图的alpha,进行alpha混合,是有渐变过渡的
					color.a*=saturate(alpha+(effectFactor*2-1));
					#elif CUTOFF//是没有渐变过渡的
					color.a*=step(0.001,color.a*alpha-1+effectFactor);
					#elif DISSOLVE

					fixed width = param1.y/4;
					fixed softness = param1.z;
					fixed3 dissolveCoor = tex2D(_ParamTex,float2(0.75,i.param.z)).rgb;
					float factor = alpha - (1-effectFactor) * (1+width)+width;//计算宽度边

					//计算渐变软边
					fixed edgeLerp = step(factor,color.a)*saturate((width-factor)*16/softness);
					color.rgb +=dissolveCoor.rgb*edgeLerp;//软边颜色
					color.a *= saturate(factor*32/softness);//宽度和软边alpha

					#endif

					color *= i.color;

					#if UNITY_UI_ALPHACLIP
					clip (color.a - 0.001);
					#endif

					return color;
				}

			ENDCG
		}
	}
}
