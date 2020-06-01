Shader "My/S_Starfield"
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
			
			float2x2 Rot(float a)
			{
				float s = sin(a);
				float c = cos(a);
				return float2x2(c, -s, s, c);
			}
			
			float Star(float2 uv, float flare)
			{
				float d = length(uv);
				float m = 0.05 / d;
				
				float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
				m += rays * flare;
				
				uv = mul(Rot(3.1415 / 4.0), uv);
				rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
				m += rays * 0.3 * flare;
				
				return m;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				uv *= 3;
				
				float3 col = float3(0, 0, 0);
				
				col += Star(uv, 1.0);
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
