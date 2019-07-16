Shader "CommonEffect/S_079_DiffuseAndEmission"
{
	Properties
	{
		[Header(Diffuse)]
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Diffuse ("Diffuse Value", Range(0, 1)) = 1.0
		[Header(Emission)]
		_MainTex ("Emissive Map", 2D) = "white" { }
		[HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0)
		_Threshold ("Threshold", Range(0, 1)) = 1.
	}
	SubShader
	{
		Tags { "LightMode" = "ForwardBase" }
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half4 col: COLOR0;
				float2 uv: TEXCOORD0;
			};
			
			half4 _Color;
			half4 _LightColor0;
			float _Diffuse;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float NDotL = max(0.0, dot(worldNormal, lightDir));
				half4 diff = _Color * NDotL * _LightColor0 * _Diffuse;
				o.col = diff;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			float4 _EmissionColor;
			float _Threshold;
			
			half4 frag(v2f i): SV_TARGET
			{
				half3 emi = tex2D(_MainTex, i.uv).r * _EmissionColor.rgb * _Threshold;
				i.col.rgb+=emi;
				return i.col;
			}
			
			
			ENDCG
			
		}
	}
}
