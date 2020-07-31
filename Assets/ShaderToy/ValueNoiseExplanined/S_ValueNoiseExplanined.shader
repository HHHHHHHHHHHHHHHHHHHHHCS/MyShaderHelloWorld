Shader "ShaderToy/S_ValueNoiseExplanined"
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
			
			float N21(float2 p)
			{
				return frac(sin(p.x * 100.0 + p.y * 6574) * 5647.0);
			}
			
			float SmoothNoise(float2 uv)
			{
				float2 lv = frac(uv);
				float2 id = floor(uv);
				
				lv = lv * lv * (3.0 - 2.0 * lv);
				
				float bl = N21(id);
				float br = N21(id + float2(1, 0));
				float b = lerp(bl, br, lv.x);
				
				float tl = N21(id + float2(0, 1));
				float tr = N21(id + float2(1, 1));
				float t = lerp(tl, tr, lv.x);
				
				return lerp(b, t, lv.y);
			}
			
			float SmoothNoise2(float2 uv)
			{
				float c = SmoothNoise(uv * 4.0);
				c += SmoothNoise(uv * 8.0) * 0.5;
				c += SmoothNoise(uv * 16.0) * 0.25;
				c += SmoothNoise(uv * 32.0) * 0.125;
				c += SmoothNoise(uv * 64.0) * 0.0625;
				
				c /= 2.0;
				
				return c;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv ;//- 0.5;
				//uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				uv += _Time.y * 0.1;
				float c = SmoothNoise2(uv);
				
				float3 col = c;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
