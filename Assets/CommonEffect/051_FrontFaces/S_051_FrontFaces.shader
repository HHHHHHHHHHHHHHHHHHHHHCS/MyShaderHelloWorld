﻿Shader "CommondEffect/S_051_FrontFaces"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_ScalarVal ("Value", Range(0.0, 1.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half2 uv: TEXCOORD0;
				fixed val: TEXCOORD1;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _ScalarVal;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = mul(UNITY_MATRIX_VP, worldPos);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.val = step(_ScalarVal, dot(worldNormal, normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz)));
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				if (i.val < 0.99)
					discard;
				half4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			
			ENDCG
			
		}
	}
}
