Shader "CommonEffect/S_092_OutlineScreenspace"
{
	Properties
	{
		[Header(Outline)]
		_OutlineVal ("Outline Value", Range(0.0, 2.0)) = 1.0
		_OutlineCol ("Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[Header(Texture)]
		[NoScaleOffset]_MainTex ("Texture", 2D) = "white" { }
		_Zoom ("Zoom", Range(0.5, 20)) = 1
		_SpeedX ("Speed Along X", Range(-1, 1)) = 0
		_SpeedY ("Speed Along Y", Range(-1, 1)) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }
		
		Pass
		{
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			
			float _OutlineVal;
			
			float4 vert(appdata_base v):SV_POSITION
			{
				float4 pos = UnityObjectToClipPos(v.vertex);
				
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				
				normal.x *= UNITY_MATRIX_P[0][0];
				normal.y *= UNITY_MATRIX_P[1][1];
				
				pos.xy += _OutlineVal * normal.xy;
				
				return pos;
			}
			
			half4 _OutlineCol;
			
			half4 frag(float4 i:SV_POSITION): SV_TARGET
			{
				return _OutlineCol;
			}
			
			ENDCG
			
		}
		
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 vert(appdata_base v): SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}
			
			sampler2D _MainTex;
			float _Zoom;
			float _SpeedX;
			float _SpeedY;
			
			half4 frag(float4 i: SV_POSITION): SV_Target
			{
				return tex2D(_MainTex, ((i.xy / _ScreenParams.xy) + float2(_Time.y * _SpeedX, _Time.y * _SpeedY)) / _Zoom);
			}
			ENDCG
			
		}
	}
}
