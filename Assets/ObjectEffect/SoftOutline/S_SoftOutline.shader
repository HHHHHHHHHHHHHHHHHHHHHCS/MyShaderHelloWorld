Shader "ObjectEffect/S_SoftOutline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BlurSize ("Blur Size", float) = 1
		_BlurTex ("Blur Tex", 2D) = "" { }
		_SrcTex ("Src Tex", 2D) = "white" { }
		_OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	uniform half4 _MainTex_TexelSize;
	// 边缘分成了硬边和软边两种。
	#pragma shader_feature _Hard_Side
	float _BlurSize;
	sampler2D _MainTex;
	sampler2D _BlurTex;
	sampler2D _SrcTex;
	half4 _OutlineColor;
	// 高斯模糊部分 ---{
		//高斯模糊权重
		static const half4 GaussWeight[7] = {
			half4(0.0205, 0.0205, 0.0205, 0),
			half4(0.0855, 0.0855, 0.0855, 0),
			half4(0.232, 0.232, 0.232, 0),
			half4(0.324, 0.324, 0.324, 1),
			half4(0.232, 0.232, 0.232, 0),
			half4(0.0855, 0.0855, 0.0855, 0),
			half4(0.0205, 0.0205, 0.0205, 0)
		};
		
		
		struct v2f_Blur
		{
			float4 pos: SV_POSITION;
			half2 uv: TEXCOORD0;
			half2 offset: TEXCOORD1;
		};
		
		//水平模糊
		v2f_Blur vertBlurHor(appdata_img v)
		{
			v2f_Blur o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.offset = _MainTex_TexelSize * half2(1, 0) * _BlurSize;
			return o;
		}
		
		//垂直模糊
		v2f_Blur vertBlurVer(appdata_img v)
		{
			v2f_Blur o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.offset = _MainTex_TexelSize * half2(0, 1) * _BlurSize;
			return o;
		}
		
		half4 fragBlur(v2f_Blur i): SV_TARGET
		{
			half2 uv_withOffset = i.uv - i.offset * 3;
			half4 col = 0;
			for (int j = 0; j < 7; j ++)
			{
				half4 texCol = tex2D(_MainTex, uv_withOffset);
				col += texCol * GaussWeight[j];
				uv_withOffset += i.offset;
			}
			return col;
		}
		
		struct v2f_Add
		{
			float4 pos: SV_POSITION;
			float2 uv: TEXCOORD0;
		};
		
		v2f_Add vertAdd(appdata_img v)
		{
			v2f_Add o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			
			//#if UNITY_UV_STARTS_AT_TOP
			//	o.uv.y = 1 - o.uv.y;
			//#endif
			return o;
		}
		
		half4 fragAdd(v2f_Add i): SV_TARGET
		{
			half4 scene = tex2D(_MainTex, i.uv);//如果是0 则可以只看边缘图
			half4 blurCol = tex2D(_BlurTex, i.uv);
			half4 srcCol = tex2D(_SrcTex, i.uv);
			#if _Hard_Side
				// 如果是硬边描边，就用模糊纹理-原来的纹理得到边缘
				half4 outlineColor = saturate(blurCol - srcCol - 0.025);//0.05是减去小点
				// all(outlineColor.rgb) 三个分量都不等于0，返回1，否则返回0.类似&&运算
				// any(outlineColor.rgb);rgb 任意不为 0，则返回 true。类似||运算
				// 如果rgb都不为0(硬边部分）就显示硬边，否则都显示scene部分。
				return scene * (1 - all(outlineColor.rgb)) + _OutlineColor * any(outlineColor.rgb);
			#else
				return saturate(blurCol - srcCol) * _OutlineColor + scene;
			#endif
		}
		
		ENDCG
		
		SubShader
		{
			//0
			Pass
			{
				ZTest Always
				Cull Off
				CGPROGRAM
				
				#pragma vertex vertBlurHor
				#pragma fragment fragBlur
				ENDCG
				
			}
			//1
			Pass
			{
				ZTest Always
				Cull Off
				CGPROGRAM
				
				#pragma vertex vertBlurVer
				#pragma fragment fragBlur
				ENDCG
				
			}
			//2
			Pass
			{
				ZTest Off
				Cull Off
				
				CGPROGRAM
				
				#pragma vertex vertAdd
				#pragma fragment fragAdd
				ENDCG
				
			}
		}
	}
