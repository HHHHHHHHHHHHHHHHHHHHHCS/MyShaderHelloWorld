//UI 流光用
Shader "UI/S_UIShiny"
{
	Properties
	{
		[PerRendererData] _MainTex ("Main Texture", 2D) = "white" { }
		_Color ("Tint", Color) = (1, 1, 1, 1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StenCilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		
		_ColorMask ("Color Mask", Float) = 15
		
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		
		[NoScaleOffset]_ParamTex ("Parameter Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
		
		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StenCilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask[_ColorMask]
		
		pass
		{
			Name "SHINYDEFAULT"
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#pragma multi_compile _ UNITY_UI_ALPHACLIP
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "UIEffectBase.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				half4 color: COLOR;
				float2 texcoord: TEXCOORD0;
				float4 worldPosition: TEXCOORD1;
				float2 param: TEXCOORD2;//参数 X是光柱的位置 Y是在图片上的索引
				
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			half4 _TextureSampleAdd;//texture颜色添加用
			float4 _ClipRect;//2D裁剪用
			half4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _ParamTex;
			
			v2f vert(a2v v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color * _Color;
				o.texcoord = UnpackToVec2(v.texcoord.x);//图片原来的uv顶点位置
				o.param = UnpackToVec2(v.texcoord.y);//这一组是光柱的中心点位置和特效组id
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half normalizedPos = i.param.x;
				
				//因为流光是两组参数 所以 取中间点 0.25 和 0.75
				half4 param1 = tex2D(_ParamTex, float2(0.25, i.param.y));
				half4 param2 = tex2D(_ParamTex, float2(0.75, i.param.y));
				half location = param1.x * 2 - 0.5;
				half width = param1.y;
				half softness = param1.z;
				half brightness = param1.w;
				half gloss = param2.w;
				
				half4 color = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd);//图片原有颜色
				half4 originAlpha = color.a;
				color *= i.color;
				color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);//裁剪看不见的UI
				
				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);//裁剪A值过小UI
				#endif
				
				
				half isOri = 1 - step(param2.x + param2.y + param2.z, 0);
				half3 glossColor = lerp(color.rgb, param2.rgb, isOri) ;
				
				half normalized = 1 - saturate(abs((normalizedPos - location) / width));//流光的位置
				isOri = isOri * (1 - step(normalized, 0));//流光是否是自定义颜色用
				half shinePower = smoothstep(0, softness * 2, normalized);//流光的软光
				shinePower = shinePower + 0.05 * isOri;//如果是自定义颜色 因为软边会发黑
				half3 reflectColor = lerp(1, glossColor * 10, gloss);//流光的曝光度
				//流光颜色*软光*光强度*曝光度的颜色
				half3 shinyColor = originAlpha * (shinePower / 2) * brightness * reflectColor;
				
				color.rgb = lerp(color.rgb + shinyColor, shinyColor, isOri);
				
				return color;
			}
			ENDCG
			
		}
	}
}
