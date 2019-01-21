//颜色替换
Shader "UI/S_UIColorReplace"
{
	Properties
	{
		[PerRendererData] _MainTex("Main Texture",2D)="white"{}

		_StencilComp("Stencil Comparison",Float)=8
		_Stencil("Stencil ID",Float)=0
		_StencilOp("Stencil Operation",Float)=0
		_StencilWriteMask("Stencil Write Mask",Float)=255
		_StencilReadMask("Stencil Read Mask",Float)=255
		_ColorMask("Color Mask",Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip",Float)=0

		_ParamTex("Paramter Texture",2D)="white"{}
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
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
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
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ UNITY_UI_ALPHACLIP

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "UIEffectBase.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float4 color:COLOR;
				float2 texcoord:TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex:SV_POSITION;
				half4 color:COLOR;
				float2 texcoord:TEXCOORD0;
				float4 wPos :TEXCOORD1;
				half param:TEXCOORD2;//特效图的index
				UNITY_VERTEX_OUTPUT_STEREO
			};

			half4 _TextureSampleAdd;//Unity管理:图片格式用Alpha8
			float4 _ClipRect;//Unity管理:2D裁剪用
			sampler2D _MainTex;
			sampler2D _ParamTex;

			v2f vert(a2v v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(O);
				o.wPos = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

				o.texcoord = UnpackToVec2(v.texcoord.x);
				o.param = v.texcoord.y;

				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 param1 =tex2D(_ParamTex,float2(0.25,i.param));
				half4 param2 = tex2D(_ParamTex,float2(0.75,i.param));
				half3 targetColor = param1.rgb;//要被替换的颜色
				half range = param1.w*3;//要被替换的范围,前面除以3了
				half3 replaceColor = param2.rgb;//被替换的颜色
				half4 color = tex2D(_MainTex,i.texcoord);

				color.a *=UnityGet2DClipping(i.wPos.xy,_ClipRect);

				//是否使用clip 隐藏
				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a-0.001);
				#endif



				half3 offset = half3(color.r-targetColor.r,color.g-targetColor.g,color.b-targetColor.b);
				half diff = abs(offset.x)+abs(offset.y)+abs(offset.z);
				half maked = step(diff,range);

				color.rgb =lerp(color.rgb,replaceColor+offset,maked);

				return (color + _TextureSampleAdd) * i.color;
			}

			ENDCG
		}

	}

}