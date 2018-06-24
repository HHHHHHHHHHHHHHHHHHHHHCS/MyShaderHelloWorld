// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "HCS/S_HalfLambert"
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
			#pragma target 3.0

			#include "Lighting.cginc"

			UNITY_INSTANCING_BUFFER_START(Props)

			UNITY_INSTANCING_BUFFER_END(Props)

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
				o.worldNormal = mul(v.normal, unity_WorldToObject);
				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
				fixed halfLambert = dot(worldNormal, worldLightDir)*0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*halfLambert;
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1);
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
