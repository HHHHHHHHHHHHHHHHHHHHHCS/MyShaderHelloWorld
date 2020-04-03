Shader "CommonEffect/S_055_WorldSpaceTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		CGPROGRAM
		
		#pragma surface surf Standard
		
		struct Input
		{
			float3 worldNormal;
			float3 worldPos;
		};
		
		sampler2D _MainTex;
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			if (abs(IN.worldNormal.y) > 0.5f)
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.xz);
			}
			else if(abs(IN.worldNormal.x) > 0.5)
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.yz);
			}
			else
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.xy);
			}
			
			o.Emission = o.Albedo;
		}
		
		ENDCG
		
	}
}
