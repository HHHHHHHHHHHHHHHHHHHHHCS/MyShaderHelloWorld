Shader "CommonEffect/S_059_VertexSpecular"
{
	Properties
	{
		[Header(Diffuse)]
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Diffuse ("Value", Range(0, 1)) = 1.0
		
		[Header(Specular)]
		_SpecColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Range(0.1, 10)) = 1
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
			
			half4 _LightColor0;
			half4 _Color;
			half4 _SpecColor;
			
			float _Diffuse;
			float _Shininess;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
				float3 refl = reflect(-lightDir, worldNormal);
				
				float NDotL = max(0.0, dot(worldNormal, lightDir));
				float RDotV = max(0.0, dot(refl, viewDir));
				
				
				half4 diff = _Color * NDotL * _LightColor0 * _Diffuse;
				half4 spec = ceil(NDotL) * _LightColor0 * _SpecColor * pow(RDotV, _Shininess);
				
				o.col = diff + spec;
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
