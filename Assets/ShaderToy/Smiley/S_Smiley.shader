Shader "My/S_Smiley"
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
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float Remap01(float a, float b, float t)
			{
				return saturate((t - a) / (b - a));
			}
			
			float Remap(float a, float b, float c, float d, float t)
			{
				return saturate((t - a) / (b - a)) * (d - c) + c;
			}
			
			float4 Eye(float2 uv)
			{
				float4 col = 0;
				
				return col;
			}
			
			float4 Mouth(float2 uv)
			{
				float4 col = 0;
				
				return col;
			}
			
			float4 Head(float2 uv)
			{
				float4 col = float4(0.9, 0.65, 0.1, 1.0);
				
				float d = length(uv);
				
				col.a = smoothstep(0.5, 0.49, d);
				
				float edgeShade = Remap01(0.35, 0.5, d);
				edgeShade *= edgeShade;
				col.rgb *= 1.0 - edgeShade * 0.5;
				
				col.rgb = lerp(col.rgb, float3(0.6, 0.3, 0.1), smoothstep(0.47, 0.48, d));
				
				float highLight = smoothstep(0.41, 0.405, d);
				highLight *= Remap(0.41, -0.1, 0.75, 0.0, uv.y);
				col.rgb = lerp(col.rgb, 1.0, highLight);
				
				d = length(uv - float2(0.25, -0.2));
				float cheeck = smoothstep(0.2, 0.1, d);
				col.rgb = lerp(col.rgb, float3(1.0, 0.1, 0.1), cheeck);
				return col;
			}
			
			float4 Smiley(float2 uv)
			{
				float4 col = 0;
				
				float4 head = Head(uv);
				
				col = lerp(col, head, head.a);
				
				return pow(col, 2.2);
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				return Smiley(uv);
			}
			ENDCG
			
		}
	}
}
