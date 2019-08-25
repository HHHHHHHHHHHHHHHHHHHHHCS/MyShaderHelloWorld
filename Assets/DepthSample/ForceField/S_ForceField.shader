Shader "HCS/S_ForceField"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (1, 1, 1, 1)
		_RimPower ("Rim Power", Range(0, 1)) = 1
		_IntersectionPower ("Intersect Power", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		
		Pass
		{
			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldViewDir: TEXCOORD1;
				float4 screenPos: TEXCOORD2;
				float eyeZ: TEXCOORD3;
			};
			
			sampler2D _CameraDepthTexture;
			half4 _MainColor;
			float _RimPower;
			float _IntersectionPower;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeZ);//越远值越大 越近越小
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(i.worldViewDir);
				float rim = 1 - saturate(dot(worldNormal, worldViewDir)) * _RimPower;
				
				//注意自己没有渲染在深度图上  远处 screenZ为1
				float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float intersect = (1 - (screenZ - i.eyeZ)) * _IntersectionPower;
				float v = max(rim, intersect);
				
				return _MainColor*v;
			}
			
			ENDCG
			
		}
	}
}
