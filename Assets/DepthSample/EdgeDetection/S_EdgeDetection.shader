Shader "DepthSample/S_EdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_EdgeThreshold ("Edge Threshold", Range(0.01, 1)) = 0.01
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
				float2 uv[5]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float _EdgeThreshold;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv;
				
				float2 uv = v.uv;
				#if UNITY_START_AT_TOP
					if (_MainTex_TexelSize.y < 0)
						uv.y = 1 - uv.y;
				#endif
				
				//Robers算法
				float2 offset = float2(1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * offset.yy;
				o.uv[2] = uv + _MainTex_TexelSize.xy * offset.yx;
				o.uv[3] = uv + _MainTex_TexelSize.xy * offset.xy;
				o.uv[4] = uv + _MainTex_TexelSize.xy * offset.xx;
				
				return o;
			}
			
			int IsSame(float d1, float d2)
			{
				return abs(d1 - d2) < _EdgeThreshold;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv[0]);
				
				float sample1 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[1])));
				float sample2 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[2])));
				float sample3 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[3])));
				float sample4 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[4])));
				
				float edge = 1.0;
				//对角线差异相乘
				edge *= IsSame(sample1, sample4);
				edge *= IsSame(sample2, sample3);
				
				
				return edge;
				//return lerp(0,col,edge);//描边
			}
			
			ENDCG
			
		}
		
		Pass
		{
			//Deferred
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
				float2 uv[5]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			//Deferred
			sampler2D _CameraNormalsTexture;
			float _EdgeThreshold;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv;
				
				float2 uv = v.uv;
				#if UNITY_START_AT_TOP
					if (_MainTex_TexelSize.y < 0)
						uv.y = 1 - uv.y;
				#endif
				
				//Robers算法
				float2 offset = float2(1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * offset.yy;
				o.uv[2] = uv + _MainTex_TexelSize.xy * offset.yx;
				o.uv[3] = uv + _MainTex_TexelSize.xy * offset.xy;
				o.uv[4] = uv + _MainTex_TexelSize.xy * offset.xx;
				
				return o;
			}
			
			int IsSame(float3 n1, float3 n2)
			{
				float3 offset = abs(n1 - n2);
				return(offset.x + offset.y + offset.z) < _EdgeThreshold;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv[0]);
				
				float3 sample0 = UnpackNormal(tex2D(_CameraNormalsTexture, i.uv[0]));
				float3 sample1 = UnpackNormal(tex2D(_CameraNormalsTexture, i.uv[1]));
				float3 sample2 = UnpackNormal(tex2D(_CameraNormalsTexture, i.uv[2]));
				float3 sample3 = UnpackNormal(tex2D(_CameraNormalsTexture, i.uv[3]));
				float3 sample4 = UnpackNormal(tex2D(_CameraNormalsTexture, i.uv[4]));
				
				float edge = 1;
				edge *= IsSame(sample1, sample0);
				edge *= IsSame(sample2, sample0);
				edge *= IsSame(sample3, sample0);
				edge *= IsSame(sample4, sample0);
				
				return edge;
				//return lerp(0, col, edge);//描边
			}
			
			ENDCG
			
		}
		
		
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
				float2 uv[5]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			//Forward
			sampler2D _CameraDepthNormalsTexture;
			float _EdgeThreshold;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv;
				
				float2 uv = v.uv;
				#if UNITY_START_AT_TOP
					if (_MainTex_TexelSize.y < 0)
						uv.y = 1 - uv.y;
				#endif
				
				//Robers算法
				float2 offset = float2(1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * offset.yy;
				o.uv[2] = uv + _MainTex_TexelSize.xy * offset.yx;
				o.uv[3] = uv + _MainTex_TexelSize.xy * offset.xy;
				o.uv[4] = uv + _MainTex_TexelSize.xy * offset.xx;
				
				return o;
			}
			
			int IsSame(float d1, float d2, float3 n1, float3 n2)
			{
				int o = 1;
				o *= abs(d1 - d2) < _EdgeThreshold;
				float3 offset = abs(n1 - n2);
				o *= (offset.x + offset.y + offset.z) < _EdgeThreshold;
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv[0]);
				
				float3 normalValues0, normalValues1, normalValues2, normalValues3, normalValues4;
				float depthValue0, depthValue1, depthValue2, depthValue3, depthValue4;
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv[0]), depthValue0, normalValues0);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv[1]), depthValue1, normalValues1);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv[2]), depthValue2, normalValues2);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv[3]), depthValue3, normalValues3);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv[4]), depthValue4, normalValues4);
				
				
				float edge = 1.0;
				edge *= IsSame(depthValue1, depthValue0, normalValues1, normalValues0);
				edge *= IsSame(depthValue2, depthValue0, normalValues2, normalValues0);
				edge *= IsSame(depthValue3, depthValue0, normalValues3, normalValues0);
				edge *= IsSame(depthValue4, depthValue0, normalValues4, normalValues0);
				
				
				
				return edge;
				//return lerp(0,col,edge);//描边
			}
			
			ENDCG
			
		}
	}
}
