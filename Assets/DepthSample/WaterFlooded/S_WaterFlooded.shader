﻿Shader "DepthSample/S_WaterFlooded"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_WaterColor ("Water Color", Color) = (0, 0, 0.8, 1)
		_WaterHeight ("Water Height", Float) = 1
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
				float4 frustumDir: TEXCOORD1;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float4x4 _FrustumDir;
			half4 _WaterColor;
			float _WaterHeight;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, v.uv);
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0)
					{
						o.uv.w = 1 - o.uv.w;
					}
				#endif
				
				int ix = (int)o.uv.z;
				int iy = (int)o.uv.w;
				
				o.frustumDir = _FrustumDir[ix + 2 * iy];
				
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv.xy);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				float linearEyeDepth = LinearEyeDepth(depth);
				float3 worldPos = _WorldSpaceCameraPos.xyz + i.frustumDir * linearEyeDepth;
				
				if(worldPos.y < _WaterHeight)
				{
					return lerp(col, _WaterColor, _WaterColor.a);
				}
				
				return col;
			}
			
			ENDCG
			
		}
	}
}
