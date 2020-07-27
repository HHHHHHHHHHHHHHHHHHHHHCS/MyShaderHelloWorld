Shader "ScreenEffect/S_SimpleLensFlare"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_OccludedSizeScale ("Occluded Size Scale", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		
		Blend One OneMinusSrcAlpha
		ColorMask RGB
		ZWrite Off
		Cull Off
		ZTest Always
		
		Pass
		{
			
			CGPROGRAM
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float4 color: COLOR;
				
				//nointerpolation 标签  不要进行插值
				//noperspective 标签 在插值期间 不执行透视
				
				// LensFlare Data :
				//		* X = RayPos
				//		* Y = Rotation (< 0 = Auto)
				//		* ZW = Size (Width, Height) in Screen Height Ratio
				nointerpolation float4 lensflare_data: TEXCOORD1;
				// World Position (XYZ) and Radius(W) :
				nointerpolation float4 worldPosRadius: TEXCOORD2;
				// LensFlare FadeData :
				//		* X = Near Start Distance
				//		* Y = Near End Distance
				//		* Z = Far Start Distance
				//		* W = Far End Distance
				nointerpolation float4 lensflare_fadeData: TEXCOORD3;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
				float4 color: COLOR;
			};
			
			sampler2D _MainTex;
			float _OccludedSizeScale;
			sampler2D _CameraDepthTexture;
			
			v2f vert(a2v v)
			{
				v2f o;
				
				float4 sunClip = UnityWorldToClipPos(v.worldPosRadius.xyz);
				float4 sc = ComputeScreenPos(sunClip);
				sc.xyz /= sc.w;//透视除法
				float3 sunScreenPos = sc.xyz ;
				float sunDepth = tex2Dlod(_CameraDepthTexture, float4(sunScreenPos.xy, 0, 0)).r;
				
				#if UNITY_REVERSED_Z
					sunDepth = 1 - sunDepth;
					sunScreenPos.z = 1 - sunScreenPos.z;
				#endif
				
				float depth = sunClip.w;//[near,far] 深度
				float2 screenPos = sunClip.xy / sunClip.w; // -1 to 1
				
				float ratio = _ScreenParams.x / _ScreenParams.y;
				//超出范围的不显示
				float occlusion = saturate(min(1 - abs(screenPos.x), 1 - abs(screenPos.y)));
				if (sunDepth < sunScreenPos.z)
					occlusion = 0;//被遮挡了不显示
				
				//深度距离渐变   过近过远都变淡
				float4 d = v.lensflare_fadeData;
				float distanceFade = saturate((depth - d.x) / (d.y - d.x));
				distanceFade *= 1.0f - saturate((depth - d.z) / (d.w - d.z));
				
				//位置和旋转
				float angle = v.lensflare_data.y;
				if (angle < 0)//自动旋转
				{
					float2 dir = normalize(screenPos);
					angle = atan2(dir.y, dir.x) + 1.5707;//让V 面对光源  不是U
				}
				
				//遮挡quad尺寸大小
				float quad_size = lerp(_OccludedSizeScale, 1.0f, occlusion) * v.lensflare_data.zw;
				//如果不显示
				if (distanceFade * occlusion == 0.0f)
					quad_size = float2(0, 0);//clip
				
				float2 local = v.vertex.xy * quad_size;
				
				local = float2(
					local.x * cos(angle) + local.y * (-sin(angle)),
					local.x * sin(angle) + local.y * cos(angle)
				);
				
				local.x /= ratio;//适应屏幕尺寸比例  成圆形
				
				//光环偏移
				float2 rayOffset = -screenPos * v.lensflare_data.x;
				o.vertex.w = v.vertex.w;
				o.vertex.xy = local + rayOffset;
				o.vertex.z = 1;
				
				o.uv = v.uv;
				
				//越靠近中心越暗
				o.color = v.color * occlusion * distanceFade * saturate(length(screenPos * 2));
				
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float4 col = tex2D(_MainTex, i.uv);
				return col * i.color;
			}
			
			ENDCG
			
		}
	}
}
