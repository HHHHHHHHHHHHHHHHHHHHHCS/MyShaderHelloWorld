//只能用于物体不动 摄像头动
//否则要保存上一帧数的深度图
Shader "HCS/S_MotionBlurDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		// No culling or depth
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
			float4x4 _CurrentInverseVP;
			float4x4 _LastVP;
			
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
				float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1);//NDC坐标
				float4 D = mul(_CurrentInverseVP, H);
				float4 W = D / D.w;//将齐次坐标W分量变1得到世界坐标
				
				float4 currentPos = H;
				float4 lastPos = mul(_LastVP, W);
				lastPos /= lastPos.w;
				
				//采样连个点所在直线上的点  进行模糊
				float2 velocity = (currentPos - lastPos) / 2.0;
				float2 uv = i.uv;
				uv += velocity;
				const int numSamples = 3;
				for (int index = 1; index < numSamples; index ++, uv += velocity)
				{
					col += tex2D(_MainTex, uv);
				}
				col /= numSamples;
				
				return col;
			}
			
			ENDCG
			
		}
	}
}
