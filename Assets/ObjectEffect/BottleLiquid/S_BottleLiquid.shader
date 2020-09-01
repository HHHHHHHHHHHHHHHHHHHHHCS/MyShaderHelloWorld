Shader "ObjectEffect/S_BottleLiquid"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		
		//液体部分
		_Height ("H", float) = 0.5
		_SectionColor ("Section Color", Color) = (1, 1, 1, 1)
		_WaterColor ("Water Color", Color) = (1, 1, 1, 1)
		_FoamColor ("FoamColor", Color) = (1, 1, 1, 1)
		_LiquidHeight ("LiquidHeight", float) = 0.1
		
		_LiquidRimColor ("Liquid Rim Color", Color) = (1, 1, 1, 1)
		_LiquidRimRange ("Liquid Rim Range", float) = 0.1
		_LiquidCameraOffset ("Liquid CameraOffset", Vector) = (0.2, 0, 0, 0)
		_LiquidRimScale ("Liquid Rim Scale", float) = 0.2
		//玻璃部分
		_Color ("Glass Color", Color) = (0.6, 0.6, 0.6, 1)
		_AlphaRange ("Alpha Range", Range(-1, 1)) = 0
		_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		_RimRange ("Rim Range", float) = 0.1
		_Raduis ("Raduis", float) = 0.1
		_CameraOffset ("Camera Offset", Vector) = (0.2, 0, 0, 0)
		
		_WaveHeight ("Wave Height", float) = 1
	}
	SubShader
	{
		Pass
		{
			Tags { "RenderType" = "Opaque" }
			Cull Off
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
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD2;
				float3 viewDir: TEXCOORD3;
				float3 worldNormal: TEXCOORD4;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _Height;
			float _LiquidHeight;
			float4  _SectionColor;
			float4 _WaterColor;
			float4 _FoamColor;
			float4 _ForceDir;
			float _WaveHeight;
			float4 _LiquidRimColor;
			float _LiquidRimRange;
			float4 _LiquidCameraOffset;
			float _LiquidRimScale;
			
			float _TargetHeight;
			
			float GetWaveHeight(float3 worldPos)
			{
				float3 disVector = float3(worldPos.x, 0, worldPos.z);
				float dis = length(disVector);
				float d = dot(disVector, _ForceDir.xyz);
				return _Height + dis * d * 0.01 * _WaveHeight;
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col;
				_TargetHeight = GetWaveHeight(i.worldPos);
				if (i.worldPos.y - _TargetHeight > 0.001)
				{
					discard;
				}
				
				float fd = dot(i.viewDir, i.worldNormal);
				
				if(fd.x < 0)
				{
					col = _SectionColor;
					return col;
				}
				else if(i.worldPos.y > (_TargetHeight - _LiquidHeight))
				{
					col.rgb = _FoamColor;
					return col;
				}
				
				float3 normal = normalize(i.worldNormal);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float NdotV = saturate(dot(normal, viewDir + _LiquidCameraOffset.xyz));
				float alpha = _LiquidRimScale * pow(1 - NdotV, _LiquidRimRange);
				half3 rim = smoothstep(float3(0, 0, 0), _LiquidRimColor, alpha);
				col.rgb = _WaterColor + rim;
				return col;
			}
			
			ENDCG
			
		}
		
		Pass
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float3 normalDir: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
			};
			
			half4 _Color;
			float _AlphaRange;
			half4 _RimColor;
			float _RimRange;
			float _Raduis;
			float4 _CameraOffset;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(vnormal.xy);
				o.vertex.xy += offset * _Raduis;//在视图空间偏移不会出现近大远小
				o.normalDir = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float3 normal = normalize(i.normalDir);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float NdotV = saturate(dot(normal, viewDir + _CameraOffset.xyz));//视线方向做了偏移，调整fresnel效果，使效果更风格化
				half3 diffuse = NdotV * _Color;
				float alpha = pow(1 - NdotV, _RimRange);
				half3 rim = _RimColor * alpha;//smoothstep(float3(0,0,0), _RimColor, alpha);
				return half4(diffuse + rim, alpha * _AlphaRange);
			}
			
			ENDCG
			
		}
	}
}
