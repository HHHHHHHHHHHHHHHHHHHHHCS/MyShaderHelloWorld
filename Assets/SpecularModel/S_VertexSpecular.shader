Shader "HCS/S_VertexSpecular" 
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20

	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0



		fixed4 _Diffuse;
		fixed4 _Specular;
		float _Gloss;

		struct a2v
		{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};

		struct v2f
		{
			float4 vertex:SV_POSITION;
			fixed3 color:COLOR;
		};

		UNITY_INSTANCING_BUFFER_START(Props)

		UNITY_INSTANCING_BUFFER_END(Props)

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 worldNormal = normalize(mul(unity_ObjectToWorld, v.normal));
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

		}

		ENDCG
	}
	FallBack "Diffuse"
}
