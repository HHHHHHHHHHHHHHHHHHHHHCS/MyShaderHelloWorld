Shader "HCS/S_RenderingDepth"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
	}
	
	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite Off
		
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
				float2 uv: TEXCOORD0;
				float4 pos: SV_POSITION;
			};
			
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float4 _MainTex_TexelSize;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				#if UNITY_UV_STARTS_AT_TOP //处理DX MSAA 会多次翻转
					if (_MainTex_TexelSize.y < 0)
						o.uv.y = 1 - o.uv.y;
				#endif
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));//UNITY_SAMPLE_DEPTH->拿出R通道
				float linear01Depth = Linear01Depth(depth);//linear+翻转用近处是0远处是1
				return linear01Depth;
			}
			
			ENDCG
			
		}
	}
}
