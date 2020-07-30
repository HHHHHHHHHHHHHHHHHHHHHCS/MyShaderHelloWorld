Shader "ShaderToy/S_PolarCoordinatesArt"
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
			
			half4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 st = float2(atan2(uv.x, uv.y), length(uv));
				
				//uv = st;
				uv = float2(st.x / 6.2831 + 0.5 + _Time.y * 0.1 + st.y, st.y);
				
				float x = uv.x * 7.0;
				float m = min(frac(x), frac(1 - x));
				float c = smoothstep(0.0, 0.1, m * 0.3 + 0.2 - uv.y);
				
				
				float3 col = 0;
				
				col.rgb = c.xxx;
				
				return float4(pow(col.rgb, 2.2), 1.0);
			}
			
			ENDCG
			
		}
	}
}