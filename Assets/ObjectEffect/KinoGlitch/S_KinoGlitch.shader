Shader "HCS/S_KinoGlitch"
{
	Properties
	{
		_MainTex ("Main Texture", 2d) = "white" { }
	}
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	float2 _MainTex_TexelSize;
	
	float2 _ScanLineJitter;//(displacement,threshold)
	//float2 _VerticalJump;//(amount,time)
	//float2 _HorizontalShake;
	//float2 _ColorDrift;//(amount,time)
	
	float nrand(float x, float y)
	{
		return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
	}
	
	half4 frag(v2f_img i): SV_TARGET
	{
		float u = i.uv.x;
		float v = i.uv.y;
		
		//随机出来的Y 能不能进行偏移  * 偏移强度
		float jitter = nrand(v, _Time.x) * 2 - 1;
		jitter *= step(_ScanLineJitter.y, abs(jitter)) * _ScanLineJitter.x;
		
		
		half4 src1 = tex2D(_MainTex, frac(float2(u + jitter, v)));
		
		return src1;
	}
	
	ENDCG
	
	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma target 3.0
			ENDCG
			
		}
	}
}
