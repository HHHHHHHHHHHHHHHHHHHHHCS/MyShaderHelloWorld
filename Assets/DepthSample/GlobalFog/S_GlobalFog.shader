Shader "DepthSample/S_GlobalFog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_FogColor ("Fog Color", Color) = (1, 1, 1, 1)
		_FogDensity ("FogDensity", Float) = 1
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
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			half4 _FogColor;
			float _FogDensity;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, v.uv);
				
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0)
						o.uv.w = 1 - o.uv.w;
				#endif
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv.xy);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				float linearDepth = Linear01Depth(depth);
				float fogDensity = saturate(linearDepth * _FogDensity);
				half4 finalColor = lerp(col, _FogColor, fogDensity);
				return  finalColor;
			}
			
			ENDCG
			
		}
	}
}
