Shader "My/S_HexagonalTilingExplained!"
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
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = (i.uv - 0.5);
				
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 col = 0;
				
				uv = abs(uv);
				
				float c = dot(uv, normalize(float2(1, 1)));
				
				col += step(c, 0.2);
				
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
