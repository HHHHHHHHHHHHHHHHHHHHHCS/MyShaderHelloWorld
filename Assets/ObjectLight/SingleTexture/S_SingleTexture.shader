Shader "ObjectLight/S_SingleTexture" 
{
	Properties 
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Texuture", 2D) = "white"{}
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
			fixed4	_Specular;
			float	_Gloss;


			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv: TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				//o.uv = v.TEXCOORD0*_MainTex_TS.xy + _MainTex.zw;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex,i.uv)*_Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT*albedo;
				
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed3 diffuse = _LightColor0* albedo*max(0,dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0 * _Specular.rgb*pow(max(0,dot(halfDir, worldNormal)), _Gloss);
				
				fixed3 color = ambient + diffuse + specular;
				
				return fixed4(color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
