Shader "CommonEffect/S_089_DepthDissolve"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		
		[Header(Dissolution)]
		_DisBegin ("Begin (The lower, the closer of the camera)", Range(0., 1.0)) = 0.
		_DisEnd ("End (Should be lower than Begin value)", Range(0., 1.0)) = 0.
		
		[Header(Ambient)]
		_Ambient ("Intensity", Range(0., 1.)) = 0.1
		_AmbColor ("Color", color) = (1., 1., 1., 1.)
		
		[Header(Diffuse)]
		_Diffuse ("Val", Range(0., 1.)) = 1.
		_DifColor ("Color", color) = (1., 1., 1., 1.)
		
		[Header(Specular)]
		[Toggle] _Spec ("Enabled?", Float) = 0.
		_Shininess ("Shininess", Range(0.1, 10)) = 1.
		_SpecColor ("Specular color", color) = (1., 1., 1., 1.)
		
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
			//#include "Assets/CommonEffect/089_DepthDissolve/ClassicNoise3D.cginc"
			#include "ClassicNoise3D.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 worldNormal: TEXCOORD2;
				float4 projPos: TEXCOORD3;
			};
			
			v2f vert(appdata_full v)
			{
				v2f o;
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				o.pos = UnityWorldToClipPos(o.worldPos);
				
				o.projPos = ComputeScreenPos(o.pos);
				
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
			
			// Dissolution
			half _DisBegin;
			float _DisEnd;
			
			// Depth texture
			sampler2D _CameraDepthTexture;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 c = tex2D(_MainTex, i.uv);
				
				float3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				
				float3 viewDir = UnityWorldSpaceLightDir(i.worldPos);
				
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
				
				half4 emi = tex2D(_EmissionTex, i.uv).r * _EmiColor * _EmiColor;
				c.rgb += emi.rgb;
				
				float depth = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r);
				
				if (depth == 1.0)
					discard;
				
				float ind = step(depth, _DisBegin) * (1.0 - (depth - _DisEnd) / (_DisBegin - _DisEnd));
				
				if((cnoise(i.worldPos) + 1.0) / 2.0 <= ind)
				discard;
				
				return c;
			}
			
			ENDCG
			
		}
	}
//如果不支持深度图
	//Fallback "Diffuse"
}
