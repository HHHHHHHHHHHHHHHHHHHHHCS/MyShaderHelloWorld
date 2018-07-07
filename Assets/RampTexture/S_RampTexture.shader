Shader "HCS/S_RampTexture" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_RampTex("Remap Texure", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
	SubShader
	{
		pass
		{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcood:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos :TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);

				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos =mul(unity_ObjectToWorld,v.vertex);
				o.uv=TRANSFORM_TEX(v.texcood,_RampTex);

				return o;
			}


			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir= normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed halfLambert = 0.5*dot(i.worldNormal,worldLightDir)+0.5;
				fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb*_Color.rgb;

				fixed3 diffuse  = _LightColor0.rgb*diffuseColor;

				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize( worldLightDir+viewDir);
				fixed3 specular = _LightColor0*_Specular*pow(max(0,dot(halfDir,worldNormal)),_Gloss);

				fixed3 color = ambient+diffuse+specular;
				return fixed4(color,1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
