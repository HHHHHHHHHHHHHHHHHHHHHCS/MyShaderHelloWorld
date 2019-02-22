Shader "CommonEffect/S_009_Mask"
{
	Properties
	{

	}
	SubShader
	{
		Tags{"RenderType" = "Transparent"}

		Stencil 
		{
			Ref 1
			Comp always
			Pass replace
		}

		CGPROGRAM
		
		#pragma surface surf Lambert alpha 

		struct Input
		{
			half3 Albedo;
		};

		void surf(Input IN,inout SurfaceOutput o)
		{
			o.Albedo = half3(1,1,1);
			o.Alpha = 0;
		}
		
		ENDCG
	}
	FallBack "Diffuse"
}
