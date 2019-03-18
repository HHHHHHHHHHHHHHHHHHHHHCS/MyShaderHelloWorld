//颜色HSV偏移
//注意gamma linear颜色的空间
Shader "UI/S_UIHSVModifier"
{
    Properties
    {
		[PerRendererData] _MainTex("Main Texture",2D)="white"{}

		_StencilComp("Stencil Comparison",Float)=8
		_Stencil("Stencil ID",Float)=0
		_StencilOp("Stencil Operation",Float)=0
		_StencilWriteMask("Stencil Write Mask",Float)=255
		_StencilReadMask("Stencil Read Mask",Float) = 255

		_ColorMask("Color Mask",Float)=15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip",Float)=0

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
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.wPos = v.vertex;
				o.vertex=UnityObjectToClipPos(v.vertex);
				o.color=v.color;
				
				o.texcoord=UnpackToVec2(v.texcoord.x);
				o.param=v.texcoord.y;

				return o;
			}

			//rgb转换成hsv
			half3 rgb2hsv(half3 c)
			{
				const half4 k = half4(0.0,-1.0/3.0,2.0/3.0,-1.0);
				const half e = 1.0e-10;//避免除以0的尴尬
				half4 p = lerp(half4(c.bg,k.wz),half4(c.gb,k.xy),step(c.b,c.g));
				half4 q = lerp(half4(p.xyw,c.r),half4(c.r,p.yzx),step(p.x,c.r));

				half d = q.x-min(q.w,q.y);
				return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			//hsv转换成rgb
			half3 hsv2rgb(half3 c)
			{
				const half4 k = half4(1.0,2.0/3.0,1.0/3.0,3.0);
				c = half3(c.x,clamp(c.yz,0.0,1.0));
				half3 p = abs(frac(c.xxx+k.xyz)*6.0-k.www);
				return c.z*lerp(k.xxx,clamp(p-k.xxx,0.0,1.0),c.y);
			}

			half4 frag(v2f i) :SV_TARGET
			{
				half4 param1 = tex2D(_ParamTex,float2(0.25,i.param));
				half4 param2 = tex2D(_ParamTex,float2(0.75,i.param));
				half3 targetHSV = param1.rgb;//要被偏移的颜色转hsv
				half3 targetRange = param1.w;//识别的范围
				half3 hsvShift = param2.xyz - 0.5;//偏移后的HSV ,C#里面+0.5 转正了,所以这里-0.5

				half4 color = tex2D(_MainTex,i.texcoord);

				color.a *= UnityGet2DClipping(i.wPos.xy,_ClipRect);//视野剔除
				//是否使用clip 隐藏
				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif

				half3 hsv = color.rgb;

				hsv = rgb2hsv(hsv);

				half3 range1 = abs(hsv - targetHSV);
				half3 range2 = 1 - range1;
				half diff = max(max(min(range2.x, range1.x), min(range2.y, range1.y) / 10), min(range2.z, range1.z) / 10);

				half masked = step(diff,targetRange);
				color.rgb = hsv2rgb(hsv + hsvShift * masked);

				return (color + _TextureSampleAdd) * i.color;//先进行颜色偏移,在做通道和颜色叠加
			}

			ENDCG
		}
	}
}