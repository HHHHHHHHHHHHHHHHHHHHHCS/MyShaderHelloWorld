Shader "HCS/S_SingleTexture" 
{
	Properties 
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
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

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				fixed3 color:COLOR;
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//float3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
				o.color= _LightColor0 * _Diffuse*saturate(dot(worldNormal, worldLightDir));
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//
				//float3 worldNormal = normalize(i.worldNormal);
				//float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//
				//fixed3 color = ambient + _LightColor0*_Diffuse*saturate(dot(worldNormal, worldLightDir));
				return fixed4(i.color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
