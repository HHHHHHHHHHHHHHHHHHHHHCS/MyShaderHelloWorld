Shader "ShaderToy/S_ToursKnots"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float2 _MousePos;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos;
				
				float3 col = float3(0, 0, 0);
				
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
