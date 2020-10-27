Shader "ObjectEffect/S_IceCartoon"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.49, 0.94, 0.64, 1)// top gradient, light green
		_TopColor ("Top Color", Color) = (0.49, 0.94, 0.64, 1)// top gradient, light green
		_BottomColor ("Bottom Color", Color) = (0.23, 0, 0.95, 1)// bottom gradient, blue
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" { }
		[Header(specular)]
		[Toggle]_Specular ("Enable Specular", Float) = 0
		[HDR]_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularOffSet ("Specular OffSet", Range(0, 1)) = 0.9
		
		[Header(Rim_Fresnel)]
		_RimBrightness ("Rim Brightness", Range(3, 4)) = 3.2 // ice rim brightness
		_Offset ("Gradient Offset", Range(-4, 4)) = 3.2 // ice rim brightness
		_InnerRimOffSet ("Inner Rim OffSet", Range(-3, 3)) = 1.5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 wNormal: NORMAL;
				float3 worldPos: TEXCOORD0;
				float3 viewDir: TEXCOORD1;
				float3 lightDir: TEXCOORD2;
			};
			
			float3 _Color;
			float3 _TopColor;
			float3 _BottomColor;
			sampler2D _Ramp;
			float _Specular;
			float3 _SpecularColor;
			float _SpecularOffSet;
			float _RimBrightness;
			float _Offset;
			float _InnerRimOffSet;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
				
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				//localpos
				float3 localPos = (i.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)));
				float3 adjustLocalPos = saturate(float3(localPos.x, localPos.y, localPos.z)).xyz + 0.4;
				
				//rim
				float softRim = 1.0 - saturate(dot(normalize(i.viewDir), i.wNormal));
				float hardRim = round(softRim);
				
				//specular
				float h = normalize(i.viewDir + i.lightDir);
				float HdotN = saturate(dot(h, i.wNormal));
				float3 specularColor = _Specular * _SpecularColor.rgb * step(_SpecularOffSet, HdotN * softRim);
				
				//emission
				float3 emission = _Color * lerp(hardRim, softRim, saturate(adjustLocalPos.x + adjustLocalPos.z)) * lerp(0, _RimBrightness, adjustLocalPos.y);
				
				float innerRim = _InnerRimOffSet +saturate(dot(normalize(i.viewDir), i.wNormal));
				float3 albedo = _Color * pow(innerRim, 0.7) * lerp(_BottomColor, _TopColor, saturate(localPos.y + _Offset)) + specularColor;
				
				float d = dot(i.wNormal, i.lightDir) * 0.5 + 0.5;
				float3 ramp = tex2D(_Ramp, float2(d, d)).rgb;
				
				float4 c;
				c.rgb = 2 * albedo * _LightColor0.rgb * ramp;
				c.a = 1;

				return c;
			}
			
			
			ENDCG
			
		}
	}
}
