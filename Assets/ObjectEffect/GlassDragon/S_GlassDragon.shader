Shader "ObjectEffect/S_GlassDragon"
{
	Properties
	{
		_Cube ("Skybox", Cube) = "" { }
		_EtaRatio ("EtaRatio", Range(0, 1)) = 0
		_FresnelBias ("Bias", float) = .5
		_FresnelScale ("Scale", float) = .5
		_FresnelPower ("Power", float) = .5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			
			
			struct appdata
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 normalDir: TEXCOORD0;
				float3 viewDir: TEXCOORD1;
			};
			
			samplerCUBE _Cube;
			float _EtaRatio;
			float _FresnelBias;
			float _FresnelScale;
			float _FresnelPower;
			
			
			//计算反射方向 reflect(I, N)
			float3 CaculateReflectDir(float3 I, float3 N)
			{
				float3 R = I - 2.f * N * dot(I, N);
				return R;
			}
			
			//计算折射方向 refract(I,N,eta)
			float3 CaculateRefractDir(float3 I, float3 N, float etaRatio)
			{
				float cosTheta = dot(-I, N);
				float cosTheta2 = sqrt(1.f - pow(etaRatio, 2) * (1 - pow(cosTheta, 2)));
				float3 T = etaRatio * (I + N * cosTheta) - N * cosTheta2;
				return T;
			}
			
			
			//菲涅耳效果
			float CaculateFresnelApproximation(float3 I, float3 N)
			{
				float fresnel = max(0, min(1, _FresnelBias + _FresnelScale * pow(min(0.0, 1.0 - dot(I, N)), _FresnelPower)));
				return fresnel;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				
				o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
				
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				return o;
			}
			
			float4 frag(v2f input): SV_TARGET
			{
				float3 reflectedDir = CaculateReflectDir(input.viewDir, input.normalDir);
				float4 reflectCol = texCUBE(_Cube, reflectedDir);
				
				float3 refractedDir = CaculateRefractDir(normalize(input.viewDir), input.normalDir, _EtaRatio);
				float4 refractCol = texCUBE(_Cube, refractedDir);
				
				//菲涅耳
				float fresnel = CaculateFresnelApproximation(input.viewDir, input.normalDir);
				
				float4 col = lerp(refractCol, reflectCol, fresnel);
				return col;
			}
			
			ENDCG
			
		}
	}
}
