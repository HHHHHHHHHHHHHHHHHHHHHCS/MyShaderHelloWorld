Shader "HCS/S_NormalMapTangentSpace" {
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
		
	}

	SubShader 
	{
		pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			LOD 200

			CGPROGRAM


			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5

			#include "Lighting.cginc"

			fixed4	_Color;
			sampler2D	_MainTex;
			float4	_MainTex_ST;
			sampler2D _BumpMap;
			float4	_BumpMap_ST;
			float _BumpScale;
			fixed4	_Specular;
			float	_Gloss;


			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
				float4 texcoord:TEXCOORD0;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv: TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;

				tangentNormal = UnpackNormal(packNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z =sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb*_Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

				fixed3 diffuse = _LightColor0.rgb*albedo*max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb*_Specular*pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;
					
				return fixed4(color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
