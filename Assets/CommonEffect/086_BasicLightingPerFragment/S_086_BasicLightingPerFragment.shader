Shader "CommonEffect/S_086_BasicLightingPerFragment"
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
			
			#pragma shader_feature _ _SPEC_ON
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 worldNormal: TEXCOORD2;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				o.pos = UnityWorldToClipPos(o.worldPos);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.uv = v.texcoord;
				
				return o;
			}
			
			sampler2D _MainTex;
			
			fixed4 _LightColor0;
			
			// Diffuse
			fixed _Diffuse;
			fixed4 _DifColor;
			
			//Specular
			fixed _Shininess;
			fixed4 _SpecColor;
			
			//Ambient
			fixed _Ambient;
			fixed4 _AmbColor;
			
			// Emission
			sampler2D _EmissionTex;
			fixed4 _EmiColor;
			fixed _EmiVal;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 c = tex2D(_MainTex, i.uv);
				
				float3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				
				float3 viewDir = UnityWorldSpaceViewDir(i.worldPos);
				
				float3 worldNormal = normalize(i.worldNormal);
				
				half4 amb = _Ambient * _AmbColor;
				
				half4 NDotL = max(0.0, dot(worldNormal, lightDir) * _LightColor0);
				half4 dif = NDotL * _Diffuse * _LightColor0 * _DifColor;
				
				half4 light = dif + amb;
				
				#if _SPEC_ON
					
					float3 refl = normalize(reflect(-lightDir, worldNormal));
					float RDotV = max(0.0, dot(refl, viewDir));
					half4 spec = pow(RDotV, _Shininess) * _LightColor0 * ceil(NDotL) * _SpecColor;
					
					light += spec;
				#endif
				
				c.rgb *= light.rgb;
				
				half4 emi = tex2D(_EmissionTex, i.uv).r * _EmiColor * _EmiVal;
				c.rgb += emi.rgb;
				
				return c;
			}
			
			ENDCG
			
		}
	}
}
