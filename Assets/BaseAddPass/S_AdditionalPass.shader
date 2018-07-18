// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "HCS/S_AdditionalPass" {
	Properties {
		_Diffuse ("Diffuse Color", Color) = (1,1,1,1)
		_Specular("Specular Color", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
	SubShader 
	{
		Tags { "LightMode"="ForwardBase" }

		LOD 200

		pass
		{
			Blend One One

			CGPROGRAM
			
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(i.vertex);

				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);

				return o;
			}

			fixed4 frag(v2f v):SV_TARGET
			{
				float3 worldPos = v.worldPos;
				fixed3 worldNormal=normalize(v.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz-worldPos.xyz);		
				#endif



				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse =_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(viewDir+worldLightDir);

				fixed3 specular=_LightColor0*_Specular*pow(max(0,dot(worldNormal, halfDir)) ,_Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten =1.0; 
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(worldPos, 1)).xyz;
				    fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;		
				#endif

				fixed3 color=ambient+(diffuse+specular)*atten;

				return fixed4(color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
