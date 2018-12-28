Shader "UI/S_UIDissolve"
{
	Properties
	{
		[PerRendererData] _MainTex ("Main Texture", 2D) = "white" { }
		_Color ("Tint", Color) = (1, 1, 1, 1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		
		_ColorMask ("Color Mask", Float) = 15
		
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		
		_ParamTex ("Parameter Texture", 2D) = "white" { }
		
		[Header]_NoiseTex ("Noise Texture(A)", 2D) = "white" { }
	}
	
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
		
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
			Name "DISSOLVE_DEFAULT"
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#pragma multi_compile _ UNITY_UI_ALPHACLIP
			#pragma shader_feature _ ADD SUBTRACT FILL
			
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
				half3 param: TEXCOORD2;//x,y顶点在噪音图的UV坐标,z特效组的索引
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			half4 _TextureSampleAdd;//Unity管理:图片格式用Alpha8
			float4 _ClipRect;//Unity管理:2D裁剪用
			half4 _Color;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _ParamTex;
			
			v2f vert(a2v v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color * _Color;
				o.texcoord = UnpackToVec2(v.texcoord.x);
				o.param = UnpackToVec3(v.texcoord.y);//x,y顶点在噪音图的UV坐标,z特效组的索引
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				//0.25第一个参数 0.75第二个参数
				half4 param1 = tex2D(_ParamTex, float2(0.25, i.param.z));
				half location = param1.x;//播放进度
				half width = param1.y / 4;//宽度,因为宽度设置1,显示就有问题了 所以/4
				half softness = param1.z;//软边
				half3 dissolveColor = tex2D(_ParamTex, float2(0.75, i.param.z));//溶解的颜色
				float cutout = tex2D(_NoiseTex, i.param.xy).a;//噪音的裁剪alpha
				
				//原有颜色
				half4 color = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd);
				
				//视野剔除
				color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				
				//因为存在width,不能直接减噪音,隐藏
				float factor = (cutout - location) + (1 - location) * width;
				
				#ifdef UNITY_UI_ALPHACLIP//裁减掉看不见的,溶解的,图片a过小的
					clip(min(color.a - 0.01, factor))
				#endif
				
				//软边,softness为0无软边,edgeLerp=step(factor, color.a)*1
				half edgeLerp = step(factor, color.a) * saturate((width - factor) * 16 / softness);
				color = ApplyColorEffect(color, half4(dissolveColor, edgeLerp));//设置溶解的叠加效果
				color.a *= saturate(factor * 32 / softness);//重新计算软边
				
				return color;
			}
			
			ENDCG
			
		}
	}
}

