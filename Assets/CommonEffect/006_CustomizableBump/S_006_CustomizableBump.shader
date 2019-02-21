Shader "CommonEffect/S_006_CustomizableBump"
{
	Properties
	{
		_MainTex("Base (RGB)",2D)="white"{}
		_Bump("Normal Map",2D)="bump"{}
		_XIntensity("Intensity",Range(-5,5)) = 0.0
		_YIntensity("Intensity",Range(-5,5)) = 0.0
	}
	SubShader
	{
		Tags{"RenderType"="Opaque"}

		CGPROGRAM

		#pragma surface surf Lambert

		sampler2D _MainTex;
		sampler2D _Bump;
		float _XIntensity;
		float _YIntensity;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_Bump;
		};

		void surf(Input IN,inout SurfaceOutput o)
		{
			half4 c =tex2D(_MainTex,IN.uv_MainTex);
			half3 n = UnpackNormal(tex2D(_Bump,IN.uv_Bump));
			n.x *= _XIntensity;
			n.y *= _YIntensity;
			o.Normal =normalize(n);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	Fallback "Diffuse"
}
