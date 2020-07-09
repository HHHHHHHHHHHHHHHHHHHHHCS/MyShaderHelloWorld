Shader "GrabPassSamples/S_Cloaking"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Cut ("Cut", Range(0, 1)) = 0.1
		_Distort ("Distort", float) = 60
	}
	SubShader
	{
		GrabPass
		{
			"_GrabTex"
		}
		
		Pass
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 normal: TEXCOORD0;
				float4 screenPos: TEXCOORD1;
				float4 worldPos: TEXCOORD2;
			};
			
			sampler2D _GrabTex;
			float2 _GrabTex_TexelSize;
			float _Cut, _Distort;
			float4 _Color;
			
			/*
			inline float4 ComputeNonStereoScreenPos(float4 pos)
			{
				float4 o = pos * 0.5f;
				o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w;
				o.zw = pos.zw;
				return o;
			}
			
			inline float4 ComputeScreenPos(float4 pos)
			{
				float4 o = ComputeNonStereoScreenPos(pos);
				#if defined(UNITY_SINGLE_PASS_STEREO)
					o.xy = TransformStereoScreenSpaceTex(o.xy, pos.w);
				#endif
				return o;
			}
			
			inline float4 ComputeGrabScreenPos (float4 pos)
			{
				#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
				#else
					float scale = 1.0;
				#endif
				float4 o = pos * 0.5f;
				o.xy = float2(o.x, o.y*scale) + o.w;
				#ifdef UNITY_SINGLE_PASS_STEREO
					o.xy = TransformStereoScreenSpaceTex(o.xy, pos.w);
				#endif
				o.zw = pos.zw;
				return o;
			}
			*/
			
			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldPos = mul(unity_ObjectToWorld, i.vertex);
				o.normal = UnityObjectToWorldNormal(i.normal);
				o.screenPos = ComputeGrabScreenPos(o.pos);
				return o;
			}
			
			float4 frag(v2f v): SV_TARGET
			{
				float4 col = 0;
				
				float3 viewDir = normalize(_WorldSpaceCameraPos - v.worldPos);
				
				//需要比较自如的控制边框的粗细，这里pow的次数需要小一点。主要
				//通过smoothstep来控制粗细。
				float alpha = pow(1 - saturate(dot(viewDir, v.normal)), 2);
				alpha = smoothstep(_Cut * (1 - 0.5), _Cut * (1 + 0.5), alpha);
				float3 diff = alpha * _Color;
				
				//伪折射
				v.screenPos.xy /= v.screenPos.w;
				v.screenPos.xy += v.normal.xy * _GrabTex_TexelSize.xy * _Distort;
				float3 c = tex2D(_GrabTex, v.screenPos.xy).xyz;
				col.xyz = lerp(c, diff, col.a);
				return col;
			}
			
			ENDCG
			
		}
	}
}