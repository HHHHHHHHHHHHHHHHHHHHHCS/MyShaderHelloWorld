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
		
		_ParamTex ("Parameter Texture", 2D) = "white" { }
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
		ZTest [UNITY_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]
		
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
			#include "../UIEffectBase/UIEffectBase.cginc"
			
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
				fixed4 color: COLOR;
				float2 texcoord: TEXCOORD0;
				float4 worldPostion: TEXCOORD1;
				half2 param: TEXCOORD2;//参数 X是光柱的位置 Y是在图片上的索引
				
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			fixed4 _TextureSampleAdd;//texture颜色添加用
			float4 _ClipRect;//2D裁剪用
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _ParamTex;
			
			v2f vert(a2v v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.worldPostion = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color * _Color;
				o.texcoord = UnpackToVec2(v.texcoord.x);//图片原来的uv顶点位置
				o.param = UnpackToVec2(v.texcoord.y);//
				return o;
			}
			
			fixed4 frag(v2f i): SV_TARGET
			{
				fixed normalizedPos = i.param.x;
				
				fixed4 param1 = tex2D(_ParamTex, float2(0.25, i.param.y));
				fixed4 param2 = tex2D(_ParamTex, float2(0.75, i.param.y));
				half location = param1.x * 2 - 0.5;
				fixed width = param1.y;
				fixed softness = param1.z;
				fixed brightness = param1.w;
				fixed gloss = param2.x;
				
				half4 color = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd);
				fixed4 originAlpha = color.a;
				color *= i.color;
				color.a *= UnityGet2DClipping(i.worldPostion.xy, _ClipRect);
				
				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);
				#endif
				
				half normalized = 1 - saturate(abs((normalizedPos - location) / width));
				half shinePower = smoothstep(0, softness * 2, normalized);
				half3 reflectColor = lerp(1, color.rgb * 10, gloss);
				
				color.rgb += originAlpha * (shinePower / 2) * brightness * reflectColor;
				return color;
			}
			ENDCG
			
		}
	}
}
