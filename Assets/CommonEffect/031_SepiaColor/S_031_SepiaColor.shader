Shader "CommonEffect/S_031_SepiaColor"
{
    Properties
    {
		_MainTex("Texture",2D)="white"{}
		_SepiaIntensity("SepiaIntensity",Range(0,1))=0
    }
    SubShader
    {
		Tags{"Queue"="Geometry" "RenderType"="Opaque"}

		CGPROGRAM

#pragma surface surf Lambert finalcolor:SepiaColor

		struct Input
		{
			float2 uv_MainTex;
};

		half _SepiaIntensity;

		void SepiaColor(Input IN, SurfaceOutput s, inout half4 col)
		{
			half3 c = col;

			c.r = dot(col.rgb, half3(0.393, 0.769, 0.189));
			c.g = dot(col.rgb, half3(0.349, 0.686, 0.168));
			c.b = dot(col.rgb, half3(0.272, 0.534, 0.131));
			col.rgb = lerp(col, c, _SepiaIntensity);
		}

		sampler2D _MainTex;

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Alpha = 1.0;
		}

		ENDCG
    }
}
