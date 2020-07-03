Shader "2DLighting/2DLight"
{
	Properties
	{
		_MainTex ("Light Texture", 2D) = "white" { }
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Attenuation ("Attenuation", Range(-1, 1)) = 1
		_Intensity ("Intensity", Float) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
		
		Lighting Off
		ZWrite Off
		Blend One One
		//0.analytic light
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "2DLighting.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
				float4 worldPos: TEXCOORD1;
				float4 shadowUV: TEXCOORD2;
			};
			
			float4 _Color;
			float _Attenuation;
			float _Intensity;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color * _Color;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.shadowUV = ComputeScreenPos(o.vertex);
				
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float dist = distance(i.texcoord, float2(0.5, 0.5));
				dist /= 0.5;
				dist = saturate(dist);
				float illum = 0;
				
				if (_Attenuation <= -1)//(-ing,-1]
				{
					illum = 0;
				}
				else if (_Attenuation <= 0)//(-1,0]
				{
					float t = 1 / (_Attenuation + 1) - 1;
					illum = exp(-dist * t) - exp(-t) * dist;
				}
				else if (_Attenuation < 1) //(0,1)
				{
					float t = 1 / (1 - _Attenuation) - 1;
					dist = 1 - dist;
					illum = 1 - (exp(-dist * t) - exp(-t) * dist);
				}
				else
				{
					illum = dist >= 1?0: 1;
				}
				
				float3 color = illum * _Intensity * _Color;
				i.shadowUV.xy /= i.shadowUV.w;
				color = color * SAMPLE_SHADOW_2D(i.shadowUV).rgb;
				
				return float4(color, 1.0);
			}
			
			ENDCG
			
		}
		
		//1.Textured light
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 color: COLOR;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float4 color: Color;
				float2 texcoord: TEXCOORD0;
				float4 worldPos: TEXCOORD1;
				float4 shadowUV: TEXCOORD2;
			};
			
			sampler2D _MainTex;
			float4 _Color;
			float _Attenuation;
			float _Intensity;
			
			sampler _ShadowMap;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color * _Color;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.shadowUV = ComputeScreenPos(o.vertex);
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float3 color = tex2D(_MainTex, i.texcoord.xy) * _Intensity * _Color;
				i.shadowUV.xy /= i.shadowUV.w;
				color = color * tex2D(_ShadowMap, i.shadowUV).rgb;
				
				return float4(color, 1.0);
			}
			
			ENDCG
			
		}
	}
}
