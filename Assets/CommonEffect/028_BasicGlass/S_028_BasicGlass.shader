Shader "CommonEffect/S_028_BasicGlass"
{
	Properties
	{
		_MainTex("Glass Main Texture",2D) = "white"{}
		_Transparency("Transparency Main Texture",Range(0,1)) = 1
		_EmissionColor("Emission Color",Color) = (1,1,1,1)
		_CubeMap("CubeMap",Cube) = "white"{}
	}

	SubShader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent"}

		CGPROGRAM

		#pragma surface surf BlinnPhong alpha

		struct Input
		{
			float2 uv_MainTex;
			float3 worldRefl;
		};

		sampler2D _MainTex;
		samplerCUBE _CubeMap;
		fixed4 _EmissionColor;
		fixed _Transparency;

		void surf(Input IN,inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex , IN.uv_MainTex);
			fixed4 w = texCUBE(_CubeMap,IN.worldRefl);
			
			o.Albedo = c.rgb;
			o.Emission =_EmissionColor.rgb * w.rgb;
			o.Specular = 0;
			o.Gloss = 1;
			o.Alpha = c.a * _EmissionColor.a * _Transparency;
		}

		ENDCG
	}

	FallBack "Transparent/VertexLit"
}
