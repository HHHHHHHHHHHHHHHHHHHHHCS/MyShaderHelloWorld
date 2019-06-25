Shader "CommonEffect/S_058_VertexLambertDiffuse"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Diffuse ("Diffuse Value", Range(0, 1)) = 1.0
	}
	SubShader
	{
		Tags { "LightMode" = "ForwardBase" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half4 col: COLOR0;
			};
			
			half4 _Color;
			half4 _LightColor0;
			float _Diffuse;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 lightDir = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld,v.vertex)));//normalize(_WorldSpaceLightPos0.xyz);
				float NDotL = max(0.0, dot(worldNormal, lightDir));
				half4 diff = _Color * NDotL * _LightColor0 * _Diffuse;
				o.col = diff;
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				return i.col;
			}
			
			ENDCG
			
		}
	}
}
