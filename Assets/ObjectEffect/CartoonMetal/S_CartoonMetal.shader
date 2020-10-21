Shader "ObjectEffect/S_CartoonMetal"
{
	Properties
	{
		[Header(Base)]
		_BaseColor ("基础颜色", Color) = (1, 1, 1, 1)
		_MainTex ("基础贴图", 2D) = "white" { }
		
		[Header(Mask)]
		_MaskTex ("MaskTex(R = Metal)", 2D) = "white" { }
		
		[Header(Specular)]
		_SpecularColor ("高光颜色", Color) = (1, 1, 1, 1)
		_Brightness ("高光强度", Range(0, 2)) = 1.3
		_OffSet ("高光偏移", Range(0, 1)) = 0.7
		
		[Header(HighLight)]
		_HighLightColor ("全反射高光颜色", Color) = (1, 1, 1, 1)
		_HighLightOffSet ("全反射高光偏移", Range(0, 1)) = 0.9
		
		[Header(Rim)]
		_RimColor ("边缘光颜色", Color) = (1, 1, 1, 1)
		_RimPower ("边缘光范围", Range(0, 20)) = 6
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
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float4 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float4 wPos: TEXCOORD1;
				float4 wNormal: TEXCOORD2;
			};
			
			sampler2D _MainTex;
			sampler2D _MaskTex;
			
			fixed4 _BaseColor;
			float _OffSet;
			fixed4 _SpecularColor;
			float _Brightness;
			
			fixed4 _HighLightColor;
			float _HighLightOffSet;
			
			fixed4 _RimColor;
			float _RimPower;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_VP, o.wPos);
				o.uv = v.uv;
				o.wNormal = mul(unity_ObjectToWorld, v.normal);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos.xyz));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wPos.xyz));
				float3 normal = normalize(i.wNormal);
				
				
				float4 mainColor = tex2D(_MainTex, i.uv);
				float4 mask = tex2D(_MaskTex, i.uv);
				
				float spec = dot(normalize(viewDir + lightDir), i.wNormal);
				
				float cutOff = step(spec, _OffSet);
				
				float3 baseAlbedo = _BaseColor * cutOff;
				float3 specularAlbedo = _SpecularColor * (1 - cutOff) * _Brightness;
				float highLight = dot(lightDir, normal);
				float3 highLightAlbedo = step(_HighLightOffSet, highLight) * _HighLightColor;
				
				float3 albedo = mainColor.rgb * (1 - mask) + (baseAlbedo + specularAlbedo + highLightAlbedo) * mask;
				
				float rim = 1 - saturate(dot(viewDir, normal));
				
				float3 emission = _RimColor.rgb * pow(rim, _RimPower);
				
				float d = dot(normal, lightDir) * 0.5 + 0.5;
				
				float4 c;
				
				c.rgb = albedo * _LightColor0.rgb + emission;
				
				c.a = 1;
				
				return c;
			}
			ENDCG
			
		}
	}
}
