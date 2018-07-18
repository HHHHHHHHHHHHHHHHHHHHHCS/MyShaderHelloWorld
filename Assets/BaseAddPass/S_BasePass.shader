Shader "HCS/S_BasePass" {
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
			CGPROGRAM
			
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

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
				fixed3 color:Color;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(i.vertex);

				float3 worldPos = mul(unity_ObjectToWorld,i.vertex);
				float3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				fixed3 worldLight =normalize( _WorldSpaceLightPos0.xyz);


				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse =_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));

				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(viewDir+worldLight);

				fixed3 specular=_LightColor0*_Specular*pow(max(0,dot(worldNormal, halfDir)) ,_Gloss);

				fixed atten =1.0;

				o.color=ambient+(diffuse+specular)*atten;

				return o;
			}

			fixed4 frag(v2f v):SV_TARGET
			{
				return fixed4(v.color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
