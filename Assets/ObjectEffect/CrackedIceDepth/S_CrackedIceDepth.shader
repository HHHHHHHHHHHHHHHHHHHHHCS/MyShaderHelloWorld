Shader "ObjectEffect/S_CrackedIceDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_IceColor ("Ice Color", Color) = (1, 1, 1, 1)
		_IceColorIntensity ("Ice Color Intensity", Range(0, 10)) = 1
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		_SamplesCount ("Sample sCount", Range(0, 32)) = 5
		_Offset ("Offset", Float) = 1
		_TheLerp ("The Lerp", Range(0, 1)) = 0.5
		_LOD ("LOD", Range(0, 10)) = 1
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
			#include "UnityLightingCommon.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 normal: NORMAL;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 wPos: TEXCOORD1;
				float3 viewDir: TEXCOORD2;
				float3 wNormal: TEXCOORD3;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;
			half4 _SpecularColor;
			half4 _IceColor;
			float _IceColorIntensity;
			float _Smoothness;
			float _SamplesCount;
			float _Offset;
			float _TheLerp;
			float _LOD;
			
			//copy by Unity_SafeNormalize
			//UCGIncludes\UnityStandardBRDF.cginc
			inline float3 TheSafeNormalize(float3 inVec)
			{
				float dp3 = max(0.001f, dot(inVec, inVec));
				return inVec * rsqrt(dp3);
			}
			
			inline half4 IceDepth(sampler2D mainTex, float2 uv, int samples, float offset, float3 wPos, float theLerp, int lod)
			{
				half4 col = 0;
				float2 uv_offset = float2(0, 0);
				float2 stepPos = _WorldSpaceCameraPos.xz - wPos.xz;
				
				for (int s = 0; s < samples; ++ s)
				{
					col += tex2Dlod(mainTex, float4(uv + uv_offset, 0, lod));//clamp(lod * s, 0, 10)));
					uv_offset += offset * stepPos;
				}
				
				col /= samples;
				return lerp(tex2D(mainTex, uv), col * _IceColor * _IceColorIntensity, theLerp);
			}
			
			inline half3 LightingSpecular(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half3 specularColor, half smoothness)
			{
				float3 halfVec = TheSafeNormalize(float3(lightDir) + float3(viewDir)); half NdotH = saturate(dot(normal, halfVec));
				half modifier = pow(NdotH, smoothness);
				half3 specularReflection = specularColor * modifier;
				return lightColor * specularReflection;
			}
			
			half3 IceSpecular(half3 specularColor, half smoothness, half3 worldNormal, half3 worldView)
			{
				smoothness = exp2(10 * smoothness + 1);
				return LightingSpecular(_LightColor0.rgb, _WorldSpaceLightPos0.xyz, worldNormal, worldView, specularColor, smoothness);
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityWorldToClipPos(o.wPos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDir = UnityWorldSpaceViewDir(o.wPos);
				o.wNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float3 worldNormal = normalize(i.wNormal);
				float3 worldView = TheSafeNormalize(i.viewDir);
				
				half4 col = IceDepth(_MainTex, i.uv, _SamplesCount, _Offset, i.wPos, _TheLerp, _LOD);
				col.rgb += IceSpecular(_SpecularColor, _Smoothness, worldNormal, worldView);
				return col;
			}
			ENDCG
			
		}
	}
}
