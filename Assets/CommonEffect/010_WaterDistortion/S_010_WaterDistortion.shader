Shader "CommonEffect/S_010_WaterDistortion"
{
	Properties
	{
		_MainTex("Main texture",2D) = "white"{}
		_NoiseTex("Noise texture",2D) = "grey"{}

		_Mitigation("Distortion mitigation",Range(1,30)) = 1
		_SpeedX("Speed along X",Range(0,5)) = 1
		_SpeedY("Speed along Y",Range(0,5)) = 1
	}
	SubShader
	{
		Tags{"RenderType" = "Opaque"}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _NoiseTex;
			float _SpeedX;
			float _SpeedY;
			float _Mitigation;

			struct v2f
			{
				half4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o ;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv= TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half2 uv = i.uv;
				half noiseVal =tex2D(_NoiseTex,uv).r;
				uv.x = uv.x + noiseVal * sin(_Time.y * _SpeedX) / _Mitigation;
				uv.y = uv.y + noiseVal * sin(_Time.y * _SpeedY) / _Mitigation;
				return tex2D(_MainTex,uv);
;			}

			ENDCG
		}
	}
}
