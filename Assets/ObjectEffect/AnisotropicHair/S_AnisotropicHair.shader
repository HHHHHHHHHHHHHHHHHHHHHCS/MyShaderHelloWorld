Shader "ObjectEffect/S_AnisotropicHair"
{
	//Copy By https://zhuanlan.zhihu.com/p/340238830
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss1 ("Gloss1", Range(8.0, 256)) = 20
		_Gloss2 ("Gloss2", Range(8.0, 256)) = 20
		_Shift1 ("Shift1", float) = 0
		_Shift2 ("Shift2", float) = 0
		_NoiseTex ("NoiseTex", 2D) = "white" { }
		_AlphaTex ("Alpha Tex", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" "IgnoreProjector" = "True" }
		
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			
			half4 _Diffuse;
			half4 _Specular;
			float _Gloss1;
			float _Gloss2;
			float _Shift1;
			float _Shift2;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			sampler2D _AlphaTex;
			float4 _AlphaTex_ST;
			
			struct a2v
			{
				float4 texcoord: TEXCOORD;
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 tangent: TANGENT;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 worldBinormal: TEXCOORD2;
				float4 uv: TEXCOORD3;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBinormal = cross(worldTangent, worldNormal);
				o.uv.xy = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half alpha = tex2D(_AlphaTex, i.uv.zw).r;
				clip(alpha - 0.5);
				
				//获取环境光
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 reflectDir = normalize(lightDir + viewDir);
				
				float shift = tex2D(_NoiseTex, i.uv.xy).r - 0.5;
				float3 worldBinormal = i.worldBinormal;
				float3 worldNormal = i.worldNormal;
				
				float3 H = normalize(lightDir + viewDir);
				//第一个高光
				float shift1 = shift - _Shift1;
				float3 worldBinormal1 = normalize(worldBinormal + shift1 * worldNormal);
				float dotTH1 = dot(worldBinormal1, H);
				float sinTH1 = sqrt(1.0 - dotTH1 * dotTH1);
				float dirAtten1 = smoothstep(-1, 0, dotTH1);
				float S1 = dirAtten1 * pow(sinTH1, _Gloss1);
				
				//第二个高光
				float shift2 = shift - _Shift2;
				float3 worldBinormal2 = normalize(worldBinormal + shift2 * worldNormal);
				float dotTH2 = dot(worldBinormal2, H);
				float sinTH2 = sqrt(1.0 - dotTH2 * dotTH2);
				float dirAtten2 = smoothstep(-1, 0, dotTH2);
				float S2 = dirAtten2 * pow(sinTH2, _Gloss2);
				
				half3 specular = _LightColor0.rgb * _Specular.rgb * (S1 + S2 * _Diffuse.rgb);
				//Lambert光照
				half3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, lightDir));
				//对高光范围进行遮罩
				specular *= saturate(diffuse * 2);
				return half4(ambient + diffuse + specular, 1.0);
			}
			
			
			ENDCG
			
		}
	}
}


/*
//获取环境光
half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
half3 AnisotropicworldNormal = normalize(lerp(i.worldNormal + i.worldBinormal, i.worldBinormal, _Tangent));
half3 lightDir =  normalize(UnityWorldSpaceLightDir(i.worldPos));
half3 viewDir =  normalize(UnityWorldSpaceViewDir(i.worldPos));
half3 reflectDir = normalize(lightDir + viewDir);
//计算反射信息
float Anisotropic = dot(AnisotropicworldNormal, reflectDir);
half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, sqrt(1 - (Anisotropic * Anisotropic))), _Gloss);
//Lanbert光照
half3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, lightDir));
//对高光范围进行遮罩
specular *= saturate(diffuse * 2);
return half4(ambient + diffuse + specular, 1.0);
*/

/*
//获取环境光
half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
half3 AnisotropicworldNormal = normalize(lerp(i.worldNormal + i.worldBinormal, i.worldBinormal, _Tangent));
half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
half3 reflectDir = normalize(lightDir + viewDir);
//计算反射信息
float LDotT = dot(AnisotropicworldNormal, lightDir);
float VDotT = dot(AnisotropicworldNormal, viewDir);
float Anisotropic = sqrt(1 - (LDotT * LDotT)) * sqrt(1 - (VDotT * VDotT)) - LDotT * VDotT;
half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, Anisotropic), _Gloss);
//Lanbert光照
half3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, lightDir));
//对高光范围进行遮罩
specular *= saturate(diffuse * 2);
*/
