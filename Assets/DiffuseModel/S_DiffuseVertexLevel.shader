// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "HCS/S_DiffuseVertexLevel" 
{
	Properties
	{
		_Diffuse("Diffuse",Color)=(1,1,1,1)
	}
	SubShader
	{
		pass
		{
			Tags {"LightMode"="ForwardBase"}
			LOD 200
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 color :COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3  ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse =_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight));

				o.color= ambient+diffuse;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				return fixed4(i.color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
