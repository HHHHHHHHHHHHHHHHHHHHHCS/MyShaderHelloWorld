Shader "TiltImage/S_TiltImage"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_NormalMap ("Normal Map", 2D) = "bump" { }
		_LightColor ("Light Color", Color) = (1, 1, 1, 1)
		_LightDir ("Light Dir", Vector) = (0, -1, 0.5)
		_StepWidth ("Step Width", float) = 1
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always Lighting Off
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _NormalMap;
			float _StepWidth;
			float4 _LightColor;
			float4 _LightDir;
			
			float4 frag(v2f_img i): SV_TARGET
			{
				half hwradio = _ScreenParams.y / _ScreenParams.x;
				half stepHeight = _StepWidth * hwradio;
				
				float2 uv = float2(floor(i.uv.x * _StepWidth) / _StepWidth, floor(i.uv.y * stepHeight) / stepHeight);
				
				half4 col = tex2D(_MainTex, uv);
				
				float2 tiltUV = frac(float2(i.uv.x * _StepWidth, i.uv.y * stepHeight));
				float3 normal = UnpackNormal(tex2D(_NormalMap, tiltUV));
				half3 lightDir = normalize(_LightDir);
				
				float3 diff = _LightColor * (saturate(dot(normal, lightDir)) * 0.5 + 0.5);
				
				return float4(col.xyz * diff, col.a);
			}
			
			
			ENDCG
			
		}
	}
}
