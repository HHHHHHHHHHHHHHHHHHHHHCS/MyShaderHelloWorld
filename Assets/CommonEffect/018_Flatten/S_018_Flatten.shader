Shader "CommonEffect/S_018_Flatten"
{
	Properties
	{
		_MainTex("Base (RGB)",2D)="white"{}
		_Elevation("Elevation",Range(0,1)) = 0
	}
	SubShader
	{
		Tags{"RenderType"="Opaque"}

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;
		fixed _Elevation;

		struct Input
		{
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v)
		{
			v.vertex.y = v.vertex.y - (1 + v.vertex.y) * _Elevation;
		}

		void surf(Input IN,inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex,IN.uv_MainTex);
			o.Albedo = c.rgb;
		}

		ENDCG
	}
}
