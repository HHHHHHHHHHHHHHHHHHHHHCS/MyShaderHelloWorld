Shader "ObjectEffect/S_BloodDecal"
{
	Properties
	{
		_Color ("Decal Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "Queue" = "Geometry+1" }
		
		ZTest GEqual
		Cull Front
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			
			//包含引用的内置文件
			#include "UnityCG.cginc"
			#include "NoiseLib.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			
			struct appdata
			{
				float4 vertex: POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 screenUV: TEXCOORD0;
				float3 ray: TEXCOORD1;
				SHADOW_COORDS(2)
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
			UNITY_INSTANCING_BUFFER_END(Props)
			
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			
			v2f vert(appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				//计算在屏幕上的位置
				o.screenUV = ComputeScreenPos(o.pos);
				//计算在viewSpace下的位置
				//因为相机空间是右手坐标 , 左手换右手 , Z 取反
				o.ray = UnityObjectToViewPos(v.vertex).xyz * float3(1, 1, -1);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			//更加锐利的样条函数
			//保证k在0~1之间
			float SmoothStepSharp01(float k)
			{
				float k2 = k * k;
				float k4 = k2 * k2;
				float k8 = k4 * k4;
				float k7 = k4 * k2 * k;
				return 8 * k7 - 7 * k8;
			}
			
			//s minVal  e midVal  k maxVal
			float SmoothstepSharp(float s, float e, float k)
			{
				float r = e - s;
				return SmoothStepSharp01((k - s) / r) * r + s;
			}
			
			
			// 根据距离加一个底色，保证靠近中心的地方是被填满的
			float DistanceAddParam(float d)
			{
				return saturate(SmoothstepSharp(0.54, 0.8, d));
			}
			
			// 根据距离加一个渐变，保证边缘锐利的消失
			float DistanceMultiParam(float d)
			{
				return saturate(SmoothstepSharp(0.4, 0.9, d));
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(i);
				i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
				float2 uv = i.screenUV.xy / i.screenUV.w;
				
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				
				//转换成线性深度
				depth = Linear01Depth(depth);
				
				float4 vpos = float4(i.ray * depth, 1);
				float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
				float3 opos = mul(unity_WorldToObject, float4(wpos, 1)).xyz;
				//裁剪掉球体之外的片元
				clip(0.5 - length(opos.xyz));
				
				//传入object space 下的坐标
				float3 r = opos.xyz;
				r = normalize(r);
				
				float gray = pnoise_fbm(r, 20, 1, 2, 0.5);

				gray = gray * 0.5 + 0.5;
				
				//给个距离叠加
				gray += DistanceAddParam(1 - length(opos.xyz));
				gray *= DistanceMultiParam(1 - length(opos.xyz));
				
				//来个锐利的裁剪
				gray = step(0.5, gray);
				
				float shadow = SHADOW_ATTENUATION(i);
				
				float4 col = float4(UNITY_ACCESS_INSTANCED_PROP(Props, _Color).rgb * shadow, gray);
				return col;
			}
			
			
			ENDCG
			
		}
	}
}
