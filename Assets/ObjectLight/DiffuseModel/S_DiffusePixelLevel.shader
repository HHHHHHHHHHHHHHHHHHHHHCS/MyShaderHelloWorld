Shader "ObjectLight/S_DiffusePixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

	SubShader
	{
		pass
		{
			Tags {"LightMode" = "ForwardBase"}
			LOD 200

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 pos:POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 worldNormal : COLOR0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.pos);
				o.worldNormal = mul(unity_ObjectToWorld,v.normal);
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLightDir));
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
