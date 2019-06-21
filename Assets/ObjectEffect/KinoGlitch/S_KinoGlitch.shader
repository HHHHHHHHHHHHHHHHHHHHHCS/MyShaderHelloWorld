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
	float2 _VerticalJump;//(amount,time)
	float _HorizontalShake;
	float2 _ColorDrift;//(amount,time)
	
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
		//左右闪动偏移
		jitter *= step(_ScanLineJitter.y, abs(jitter)) * _ScanLineJitter.x;
		
		//插值取纵向跳跃屏幕
		float jump = lerp(v, frac(v + _VerticalJump.y), _VerticalJump.x);
		
		//左右大偏移
		float shake = (nrand(_Time.x, 2) - 0.5) * _HorizontalShake;
		
		//float jump = lerp(v, frac(v + _VerticalJump.y), _VerticalJump.x);
		float drift = sin(_ColorDrift.y) * _ColorDrift.x;
		
		half4 src1 = tex2D(_MainTex, frac(float2(u + jitter + shake, jump)));
		half4 src2 = tex2D(_MainTex, frac(float2(u + jitter + shake + drift, jump)));
		
		return half4(src1.r, src2.g, src1.b, 1);
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
