Shader "ShaderToy/S_HexagonalTiling"
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
			
			#define mod(uv, m) float2(uv.x - floor(uv.x / m.x) * m.x, uv.y - floor(uv.y / m.y) * m.y)
			
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
			
			float4 HexCoords(float2 uv)
			{
				const float2 r = float2(1.0, 1.73);
				const float2 h = r * 0.5;
				
				float2 a = mod(uv, r) - h;
				float2 b = mod((uv - h), r) - h;
				
				float2 gv = length(a) < length(b)?a: b;
				
				float x = atan2(gv.x, gv.y);
				float y = 0.5 - HexDist(gv);
				
				float2 id = uv - gv;
				
				return float4(x, y, id);
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 col = 0;
				
				uv *= 10;
				
				float4 hc = HexCoords(uv + 100.0);
				
				float c = smoothstep(0.01, 0.03, hc.y * sin(hc.z * hc.w + _Time.y));
				
				col += c;
				
				return float4(pow(col, 2.2), 1);
			}
			ENDCG
			
		}
	}
}
