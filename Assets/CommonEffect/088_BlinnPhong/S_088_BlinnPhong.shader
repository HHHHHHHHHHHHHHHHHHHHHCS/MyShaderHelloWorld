Shader "CommonEffect/S_088_BlinnPhong"
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
		_Shininess ("Shinness", Range(0.1, 100)) = 1.0
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		
		[Header(Emission)]
		_EmissionTex ("Emission texture", 2D) = "gray" { }
		_EmiVal ("Intensity", float) = 0.
		[HDR]_EmiColor ("Color", color) = (1., 1., 1., 1.)
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
			
			half4 _LightColor0;
			
			// Diffuse
			half _Diffuse;
			half4 _DifColor;
			
			//Specular
			half _Shininess;
			half4 _SpecColor;
			
			//Ambient
			half _Ambient;
			half4 _AmbColor;
			
			// Emission
			sampler2D _EmissionTex;
			half4 _EmiColor;
			half _EmiVal;
			
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
					
					float3 HalfVector = normalize(lightDir + viewDir);
					float NDotH = max(0.0, dot(worldNormal, HalfVector));
					half4 spec = max(0.0, dot(worldNormal, lightDir))*pow(NDotH, _Shininess) * _LightColor0 * _SpecColor;
					
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
