Shader "CommonEffect/S_085_BasicLightingPerVertex"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		
		[Header(Ambient)]
		_Ambient ("Intensity", Range(0.0, 1.0)) = 0.1
		_AmbColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		
		[Header(Diffuse)]
		_Diffuse ("Val", Range(0.0, 1.0)) = 1.0
		_DifColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		
		[Header(Specular)]
		[Toggle] _Spec ("Enabled?", float) = 0.0
		_Shininess ("Shininess", Range(0.1, 10)) = 1.0
		_SpecColor ("Soecular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		
		[Header(Emission)]
		_EmissionTex ("Emission texture", 2D) = "gray" { }
		_EmiVal ("Intensity", float) = 0.0
		[HDR]_EmiColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		Pass
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardBase" }
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			//在C#中 用keyword 在编译阶段  也可以用 [Toggle]
			#pragma shader_feature _ _SPEC_ON
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				half4 light: COLOR0;
			};
			
			half4 _LightColor0;
			
			//Diffuse
			half _Diffuse;
			half4 _DifColor;
			
			//Specular
			half _Shininess;
			half4 _SpecColor;
			
			//Ambient
			half _Ambient;
			half4 _AmbColor;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				o.pos = mul(UNITY_MATRIX_VP, worldPos);
				
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				float3  worldNormal = UnityObjectToWorldNormal(v.normal);
				
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos.xyz));
				
				
				half4 amb = _Ambient * _AmbColor;
				
				half4 NDotL = max(0.0, dot(worldNormal, lightDir) * _LightColor0);
				half4 dif = NDotL * _LightColor0 * _Diffuse * _DifColor;
				
				o.light = dif + amb;
				
				#if _SPEC_ON
					
					float3 refl = reflect(-lightDir, worldNormal);
					float RDotV = max(0.0, dot(refl, viewDir));
					half4 spec = pow(RDotV, _Shininess) * _LightColor0 * ceil(NDotL) * _SpecColor;
					
					o.light += spec;
					
				#endif
				
				o.uv = v.texcoord;
				
				return o;
			}
			
			sampler2D _MainTex;
			
			sampler2D _EmissionTex;
			half4 _EmiColor;
			half _EmiVal;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				col.rgb *= i.light;
				
				half4 emi = tex2D(_EmissionTex, i.uv).r * _EmiColor * _EmiVal;
				col.rgb += emi.rgb;
				return col;
			}
			
			ENDCG
			
		}
	}
}
