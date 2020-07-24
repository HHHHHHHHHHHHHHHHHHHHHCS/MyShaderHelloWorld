Shader "ObjectEffect/Outline" 
{
	Properties
	{
		_Color("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline width", Range(0.0, 1)) = 0.5
		_MainTex("Base (RGB)", 2D) = "white" { }
	}

	SubShader
	{
		pass
		{

			Cull Off
            ZWrite Off
            ZTest Always

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

			float _Outline;
			float4 _OutlineColor;

			v2f vert(appdata v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.vertex);//也可以把v.vertex换成normal试一试
				float2 offset = TransformViewToProjection(norm.xy);

				o.pos.xy += offset * o.pos.z * _Outline;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				return _OutlineColor;
			}

			ENDCG
		}

		pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			struct a2v 
			{
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv= TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				fixed4 col =tex2D(_MainTex,i.uv)*_Color;
				return col;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}