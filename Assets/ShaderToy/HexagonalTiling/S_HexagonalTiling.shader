Shader "My/S_HexagonalTiling"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		
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
			
			float HexDist(float2 p)
			{
				p = abs(p);
				
				float c = dot(p, normalize(float2(1, 1.73)));
				c = max(c, p.x);
				
				return c;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 col = 0;
				
				float2 gv = frac(uv * 10.0);
				
				col.rg = gv;//sin(HexDist(uv) * 10.0 + _Time.y);
				
				return float4(pow(col, 2.2), 1);
			}
			ENDCG
			
		}
	}
}
