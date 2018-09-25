Shader "HCS/S_MyFirstLighting" {
	Properties 
	{
		_Tint("Main Color",color)=(1,1,1,1)
		_MainTex ("Main Map", 2D) = "white" {}
		//_SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
		[Gamma] _Metallic("Metallic",Range(0,1))=0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}
	SubShader 
	{
		pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag
			//#include "UnityCG.cginc"
			//#include "UnityStandardBRDF.cginc"
			//#include "UnityStandardUtils.cginc"
			#include "UnityPBSLighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			uniform fixed4 _Tint;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _SpecularTint;
			uniform float _Metallic;
			uniform float _Smoothness;

			v2f vert(a2v i)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(i.vertex);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.uv=TRANSFORM_TEX(i.texcoord,_MainTex);
				o.normal= UnityObjectToWorldNormal(i.normal);
				return o;
			}

			/*
			fixed4 frag(v2f i):SV_TARGET
			{
				i.normal=normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;
				float3 viewDir=normalize(_WorldSpaceCameraPos-i.worldPos);

				float3 albedo = tex2D(_MainTex,i.uv).rgb*_Tint.rgb ;
				//albedo *= 1 - max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));
				
				//float oneMinusReflectivity;
				//albedo=EnergyConservationBetweenDiffuseAndSpecular(albedo,_SpecularTint.rgb,oneMinusReflectivity);
				
				//float3 specularTint=albedo*_Metallic;
				//float oneMinusReflectivity=1-_Metallic;
				//albedo*=oneMinusReflectivity;

				float3 specularTint;
				float oneMinusReflectivity;
				albedo=DiffuseAndSpecularFromMetallic(albedo,_Metallic,specularTint,oneMinusReflectivity);
				
				float3 diffuse = albedo*lightColor * DotClamped(lightDir, i.normal);
	


				float3 reflectionDir = reflect(-lightDir, i.normal);
				float3 phongSpec= _SpecularTint*lightColor *pow(DotClamped(viewDir, reflectionDir),_Smoothness * 100);
				float3 halfVector = normalize(lightDir + viewDir);
				float3 blinnPhongSpec=_SpecularTint*lightColor *pow(DotClamped(halfVector, i.normal),_Smoothness * 100);

				return fixed4(diffuse+phongSpec,1);
			}
			*/

			fixed4 frag(v2f i):SV_TARGET
			{
				i.normal = normalize(i.normal);	
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);
				
				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir);
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light, indirectLight
				);
			}		

			ENDCG
		}
	}
	FallBack "Diffuse"
}
