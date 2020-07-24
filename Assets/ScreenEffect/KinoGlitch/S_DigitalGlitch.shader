﻿Shader "ScreenEffect/S_DigitalGlitch"
{
	Properties
	{
		_MainTex ("-", 2D) = "" { }
		_NoiseTex ("-", 2D) = "" { }
		_TrashTex ("-", 2D) = "" { }
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _NoiseTex;
	sampler2D _TrashTex;
	float _Intensity;
	
	float4 frag(v2f_img i): SV_TARGET
	{
		float4 glitch = tex2D(_NoiseTex, i.uv);
		
		float thresh = 1.001 - _Intensity * 1.001;//是否要偏移
		float w_d = step(thresh, pow(glitch.z, 2.5)); // displacement glitch
		float w_f = step(thresh, pow(glitch.w, 2.5)); // frame glitch
		float w_c = step(thresh, pow(glitch.z, 3.5)); // color glitch
		
		//区域块UV偏移
		float2 uv = frac(i.uv + glitch.xy * w_d);
		float4 source = tex2D(_MainTex, uv);
		
		//或者跟之前图混合
		float3 color = lerp(source, tex2D(_TrashTex, uv), w_f).rgb;
		
		//颜色取灰
		float3 neg = saturate(color.grb + (1 - dot(color, 1)) * 0.5);
		color = lerp(color, neg, w_c);

		return float4(color, source.a);
	}
	
	ENDCG
	
	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma target 3.0
			ENDCG
			
		}
	}
}
