Shader "BlitCameraMotionVectors/S_BlitCameraMotionVectors"
{
	Properties { }
	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite Off
		Lighting Off
		
		//0
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D_half _MainTex;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = float4(v.vertex.xy, 0, 1);
				#if UNITY_UV_STARTS_AT_TOP
					o.uv = (v.vertex.xy + float2(1, 1)) / 2.0;
					o.uv.y = 1 - o.uv.y;
				#else
					o.uv = (v.vertex.xy + float2(1, 1)) / 2.0;
				#endif
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				return float4(tex2D(_MainTex, i.uv).rg, 0, 1);
			}
			ENDCG
			
		}
		
		//1
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = float4(v.vertex.xy, 0, 1);
				#if UNITY_UV_STARTS_AT_TOP
					o.uv = (v.vertex.xy + float2(1, 1)) / 2.0;
					o.uv.y = 1 - o.uv.y;
				#else
					o.uv = (v.vertex.xy + float2(1, 1)) / 2.0;
				#endif
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				return float4(tex2D(_MainTex, i.uv).rgb, 1);
			}
			ENDCG
			
		}
	}
}
