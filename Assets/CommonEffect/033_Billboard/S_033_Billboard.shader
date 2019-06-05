﻿Shader "Command/S_033_Billboard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata_base v)
			{
				v2f o ;
				o.pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)))
				+ float4(v.vertex.x, v.vertex.y, 0, 0);
				v.texcoord.y = 1 - v.texcoord.y;
				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			
			ENDCG
			
		}
	}
}
