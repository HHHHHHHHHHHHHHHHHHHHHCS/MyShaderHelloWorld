Shader "CommonEffect/S_005_ScrollingUV"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white"{}
		_TextureColor ("Texture Color",Color) = (1,1,1,1)
		_ScrollXSpeed ("X Scroll Speed",Range(-5,5)) = 0
		_ScrollYSpeed ("Y Scroll Speed",Range(-5,5)) = 0
	}
	SubShader
	{
		
		Tags {"RenderType"="Opaque"}

		CGPROGRAM

		#pragma surface surf Lambert alpha

		sampler2D _MainTex;
		half4 _TextureColor;
		half _ScrollXSpeed;
		half _ScrollYSpeed;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN,inout SurfaceOutput o)
		{
			half varX = _ScrollXSpeed * _Time;
			half varY = _ScrollYSpeed * _Time;
			half2 uv_Tex = IN.uv_MainTex + half2(varX,varY);
			half4 c = tex2D(_MainTex,uv_Tex) * _TextureColor;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	Fallback "Diffuse"
}
