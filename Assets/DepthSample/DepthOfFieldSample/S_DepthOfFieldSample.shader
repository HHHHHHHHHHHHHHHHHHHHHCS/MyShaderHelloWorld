Shader "HCS/S_DepthOfFieldSample"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_FocusDistance ("Focus Distance", Range(0, 1)) = 0
		_FocusLevel ("Focus Level", Float) = 3
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
			sampler2D _BlurTex;
			sampler2D _CameraDepthTexture;
			float _FocusDistance;
			float _FocusLevel;
			
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
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv.xy);
				half4 blurCol = tex2D(_BlurTex, i.uv.zw);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				depth = Linear01Depth(depth);
				float v = saturate(abs(depth - _FocusDistance) * _FocusLevel);
				return lerp(col, blurCol, v);
			}
			
			ENDCG
			
		}
	}
}
