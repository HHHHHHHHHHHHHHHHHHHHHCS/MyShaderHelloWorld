Shader "HCS/RoundedCube"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[KeywordEnum(X, Y, Z)] _Faces ("Faces", Float) = 0
	}

	SubShader
	{
		pass
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma shader_feature _FACES_X _FACES_Y _FACES_Z
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color:COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				#if defined(_FACES_X)
					o.uv = v.color.yz*255;
				#elif defined(_FACES_Y)
					o.uv = v.color.xz*255;
				#elif defined(_FACES_Z)
					o.uv = v.color.xy*255;
				#endif
				o.uv=TRANSFORM_TEX(o.uv,_MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				return col;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
