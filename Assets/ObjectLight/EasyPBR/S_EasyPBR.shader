Shader "Custom/S_EasyPBR"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("Albedo",2D) = "white"{}
		_Glossiness("Smoothness",Range(0.0,1.0)) = 0.5
		_SpecColor("Specular",Color) = (0.2,0.2,0.2) // 高光颜色
		_SpecGlossMap("Specular (RGB) Smoothness(A)",2D) = "white"{} //高光反射颜色贴图 和 粗糙度
		_BumpScale("Bump Scale",Float) = 1.0
		_BumpMap("Normal Map",2D) = "bump"{}
		_EmissionColor("Color",Color) = (0,0,0)
		_EmissionMap("Emission",2D) = "white"{}
	}

	SubShader
	{
		Tags{"RenderType" = "Opaque"}
		LOD 300

		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma target 3.0

			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 :TEXCOORD2;
				float4 TtoW2 :TEXCOORD3;
				SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)
			};


			v2f vert(a2v v)
			{
				v2f o;
				UNITY_INITALIZE_OUTPUT(v2f,o);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				TRANSFER_SHADOW(o); // We need this for shadow receving

				UNITY_TRANSFER_FOG(o,o.pos); // We need this for fog rendering

				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 specGloss = tex2D(_SpecGlossMap,i.uv);
				specGloss.a *= _Glossiness;
				half3 specColor = specGloss.rgb * _SpecColor.rgb;
				half rougness = 1 - specGloss.a;

				half oneMinusReflectivity = 1 - max(max(specColor.r,specColor.g),specColor.b);

				half3 diffColor = _Color.rgb * tex2D(_MainTex,i.uv)*oneMinusReflectivity;

				half3 normalTangent = UnpackNormal(tex2D(_BumpMap,i.uv));
				normalTangent.xy *= _BumpScale;
				normalTangent.z = sqrt(1.0-saturate(dot(normalTangent.xy,normalTangent.xy)));
				half3 normalWorld = normalize(half3(dot(i.TtoW0.xyz,normalTangent),dot(i.TtoW1.xyz,normalTangent),dot(i.TtoW2.xyz,normalTangent)));

				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

				half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				half3 reflDir = reflect(-viewDir,normalWorld);

				UNITY_LIGHT_ATTENUATION(atten,i,worldPos);

				half3 halfDir = normalize(lightDir+viewDir);
				half nv = saturate(dot(normalWorld,viewDir));
				half nl = saturate(dot(normalWorld,lightDir));
				half nh = saturate(dot(normalWorld,halfDir));
				half lv = saturate(dot(lightDir,viewDir));
				half lh = saturate(dot(lightDir,halfDir));
			}

			ENDCG
		}
	}
}
