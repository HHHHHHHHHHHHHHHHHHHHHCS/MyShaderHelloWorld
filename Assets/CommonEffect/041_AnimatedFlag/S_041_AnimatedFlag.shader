Shader "CommonEffect/S_041_AnimatedFlag"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" { }
		_Speed ("Speed", Range(0, 5.0)) = 1
		_Frequency ("Frequency", Range(0, 1.3)) = 1
		_Amplitude ("Amplitude", Range(0, 5.0)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Speed;
			float _Frequency;
			float _Amplitude;
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				v.vertex.y += cos((v.vertex.x + _Time.y * _Speed) * _Frequency) * _Amplitude * (v.vertex.x - 5);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				return tex2D(_MainTex, i.uv);
			}
			
			ENDCG
			
		}
	}
}
