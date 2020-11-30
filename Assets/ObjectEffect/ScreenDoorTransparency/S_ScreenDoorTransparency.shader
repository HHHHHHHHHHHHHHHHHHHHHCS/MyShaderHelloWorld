Shader "ObjectEffect/S_ScreenDoorTransparency"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" { }
		_Transpaarency ("Transparency", Range(0, 1)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType" = "AlphaTest" "Queue" = "AlphaTest" }
		LOD 10
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float4 screenPos: TEXCOORD1;
				float4 wPos: TEXCOORD2;
			};
			
			sampler2D _MainTex;
			float _Transpaarency;
			
			
			v2f vert(a2v v)
			{
				v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_VP, o.wPos);
				o.uv = v.uv;
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4x4 thresholdMatrix = {
					1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
					13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
					4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
					16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
				};
				float4x4 rowAccess = {
					1, 0, 0, 0,
					0, 1, 0, 0,
					0, 0, 1, 0,
					0, 0, 0, 1
				};
				float4 albedo = tex2D(_MainTex, i.uv);
				float3 viewPos = i.screenPos.xyz / i.screenPos.w;
				float2 screenPos = floor(viewPos.xy * _ScreenParams.xy / 2);
				
				
				//clip(_Transpaarency - thresholdMatrix[fmod(screenPos.x, 4)] * rowAccess[fmod(screenPos.y, 4)]);
				
				
				// float depth = (viewPos.z);
				// depth = LinearEyeDepth(depth);
				// clip(depth * 0.5 - thresholdMatrix[fmod(screenPos.x, 4)] * rowAccess[fmod(screenPos.y, 4)]);
				
				float3 dis = length(i.wPos - _WorldSpaceCameraPos);
				clip(pow(dis,2) - thresholdMatrix[fmod(screenPos.x, 4)] * rowAccess[fmod(screenPos.y, 4)]);
				
				
				return albedo;
			}
			ENDCG
			
		}
	}
}
