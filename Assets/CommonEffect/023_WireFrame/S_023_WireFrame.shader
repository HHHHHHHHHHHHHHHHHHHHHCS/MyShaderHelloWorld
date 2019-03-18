Shader "CommonEffect/S_023_WireFrame"
{
	Properties
	{
		_LineColor("LineColor",Color) = (1,1,1,1)
		_MainColor("MainColor",Color) = (1,1,1,1)
		_LineWidth("Line Width",Range(0,1)) = 0.1
		_ParceSize("ParceSize",Range(0,100)) = 1
	}
	
	SubShader
	{
		Tags{"Queue"="Transparent" "RenderType" = "Transparent"}

		CGPROGRAM

		#pragma surface surf Lambert alpha

		sampler2D _MainTex;
		float4 _LineColor;
		float4 _MainColor;
		fixed _LineWidth;
		float _ParceSize;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
		};

		void surf(Input IN,inout SurfaceOutput o)
		{
			//half val1 = step(_LineWidth*2,frac(IN.worldPos.x/_ParceSize)+_LineWidth);
			//half val2 = step(_LineWidth*2,frac(IN.worldPos.z/_ParceSize)+_LineWidth);
			half val1 = step(_LineWidth,frac(IN.worldPos.x/_ParceSize));
			val1 *= step(_LineWidth,1-frac(IN.worldPos.x/_ParceSize));//可注释
			half val2 = step(_LineWidth,frac(IN.worldPos.z/_ParceSize));
			val2 *= step(_LineWidth,1-frac(IN.worldPos.z/_ParceSize));//可注释
			fixed val = 1 - (val1 * val2);
			o.Albedo = lerp(_MainColor,_LineColor,val);
			o.Alpha = 1;
		}

		ENDCG
	}
}
