//UI 图片特效用
Shader "UI/S_UIEffect"
{
	Properties
	{
		[PerRendererData] _MainTex("Main Texture",2D)="white"{}
		_Color("Tint",Color) = (1,1,1,1)

		_StencilComp("Stencil Comparsion",Float)=8
		_Stencil("Stencil ID",Float)=0
		_StencilOp("Stencil Operation",Float)=0
		_StencilWriteMask("Stencil Write Mask",Float)=255
		_StenCilReadMask("Stencil Read Mask",Float)=255

		_ColorMask("Color Mask",Float)=15

		[Toggle(UNITY_UI_ALPHACLIP)]_UseUIAlphaClip("Use Alpha Clip",Float)=0

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
			Name "UIEFFECT_DEFAULT"

			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 3.0

				#pragma multi_compile _ UNITY_UI_ALPHACLIP

				#pragma shader_feature _ GRAYSCALE SEPIA NEGA PIXEL
				#pragma shader_feature _ ADD SUBTRACT FILL
				#pragma shader_feature _ FASTBLUR MEDIUMBLUR DETAILBLUR
				#pragma shader_feature _ EX

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"
				#include "UIEffectBase.cginc"

				struct a2v
				{
					float4 vertex :POSITION;
					float4 color :COLOR;
					float2 texcoord:TEXCOORD;

					#if defined(EX)
					float2 uvMask:TEXCOORD1;
					#endif

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex:SV_POSITION;
					float4 color:COLOR;
					float2 texcoord:TEXCOORD0;
					float4 worldPosition:TEXCOORD1;
					
					half param :TEXCOORD2;
					#if defined(EX)
					half4 uvMask:TEXCOORD3;
					#endif

					UNITY_VERTEX_OUTPUT_STEREO
				};

				half4 _TextureSampleAdd;//Unity管理:图片格式用Alpha8
				float4 _ClipRect;//Unity管理:2D裁剪用
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_TexelSize;
				sampler2D _ParamTex;

				v2f vert(a2v v)
				{
					v2f o;
					o.vertex=UnityObjectToClipPos(v.vertex);
					return o;
				}

				half4 frag(v2f i):SV_TARGET
				{
					return half4(1,1,1,1);
				}

			ENDCG
		}
	}
}
