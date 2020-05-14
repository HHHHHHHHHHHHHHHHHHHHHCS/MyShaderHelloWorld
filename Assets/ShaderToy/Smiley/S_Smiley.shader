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
			
			float2 _MousePos;
			
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
			
			float2 Within(float2 uv, float4 rect)
			{
				return(uv - rect.xy) / (rect.zw - rect.xy);
			}
			
			float4 Brow(float2 uv)
			{
				float y = uv.y;
				uv.y += uv.x * 0.8 - 0.3;
				uv.x -= 0.1;
				uv -= 0.5;
				
				float4 col = 0.0;
				
				float blur = 0.1;
				
				float d1 = length(uv);
				float s1 = smoothstep(0.45, 0.45 - blur, d1);
				float d2 = length(uv - float2(0.1, -0.2) * 0.7);
				float s2 = smoothstep(0.5, 0.5 - blur, d2);
				
				float browMask = saturate(s1 - s2);
				
				float colMask = Remap01(0.7, 0.8, y) * 0.75;
				colMask *= smoothstep(0.6, 0.9, browMask);
				float4 browCol = lerp(float4(0.4, 0.2, 0.2, 1.0), float4(1.0, 0.75, 0.5, 1.0), colMask) ;
				
				
				uv.y += 0.15;
				blur += 0.1;
				d1 = length(uv);
				s1 = smoothstep(0.45, 0.45 - blur, d1);
				d2 = length(uv - float2(0.1, -0.2) * 0.7);
				s2 = smoothstep(0.5, 0.5 - blur, d2);
				float shadowMask = saturate(s1 - s2);
				
				col = lerp(col, float4(0., 0., 0., 1.), smoothstep(.0, 1., shadowMask) * .5);
				
				col = lerp(col, browCol, smoothstep(.2, .4, browMask));
				
				return col;
			}
			
			float4 Eye(float2 uv, int side, float2 m, float smile)
			{
				uv -= 0.5;
				uv.x *= side;
				
				float d = length(uv);
				float4 irisCol = float4(0.3, 0.5, 1.0, 1.0);
				float4 col = lerp(1.0, irisCol, smoothstep(0.1, 0.7, d) * 0.5);
				col.a = smoothstep(0.5, 0.48, d);
				
				col.rgb *= 1.0 - smoothstep(0.45, 0.5, d) * 0.5 * saturate(-uv.y - uv.x * side);
				
				d = length(uv - m * 0.5);
				col.rgb = lerp(col.rgb, 0.0, smoothstep(0.3, 0.28, d));
				irisCol.rgb *= 1.0 + smoothstep(0.3, 0.05, d);
				float irisMask = smoothstep(0.28, 0.25, d);
				col.rgb = lerp(col.rgb, irisCol, irisMask);
				
				d = length(uv - m * 0.6);
				float pupileSize = lerp(0.4, 0.16, smile);
				float pupilMask = smoothstep(pupileSize, pupileSize * 0.85, d);
				col.rgb = lerp(col.rgb, 0.0, pupilMask);
				
				float highLight = smoothstep(0.1, 0.09, length(uv - float2(-0.15, 0.15)));
				highLight += smoothstep(0.07, 0.05, length(uv + float2(-0.08, 0.08)));
				
				col.rgb = lerp(col.rgb, 1.0, highLight);
				
				return col;
			}
			
			float4 Mouth(float2 uv)
			{
				uv -= 0.5;
				
				float4 col = float4(0.5, 0.18, 0.05, 1.0);
				
				uv.y *= 1.5;
				uv.y -= uv.x * uv.x * 2.0;
				float d = length(uv);
				
				col.a = smoothstep(0.5, 0.48, d);
				
				float td = length(uv - float2(0.0, 0.6));
				
				float3 toothCol = 1.0 * smoothstep(0.6, 0.35, d);
				col.rgb = lerp(col.rgb, toothCol, smoothstep(0.4, 0.37, td));
				
				td = length(uv + float2(0.0, 0.5));
				col.rgb = lerp(col.rgb, float3(1.0, 0.5, 0.5), smoothstep(0.5, 0.2, td));
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
				highLight *= smoothstep(0.18, 0.19, length(uv - float2(0.21, 0.08)));
				col.rgb = lerp(col.rgb, 1.0, highLight);
				
				d = length(uv - float2(0.25, -0.2));
				float cheeck = smoothstep(0.2, 0.01, d) * 0.4;
				cheeck *= smoothstep(0.17, 0.16, d);
				col.rgb = lerp(col.rgb, float3(1.0, 0.1, 0.1), cheeck);
				return col;
			}
			
			float4 Smiley(float2 uv, float2 m, float smile)
			{
				float4 col = 0;
				
				int side = sign(uv.x);
				uv.x = abs(uv.x);
				float4 head = Head(uv);
				float4 eye = Eye(Within(uv, float4(.03, -0.1, 0.37, 0.25)), side, m, smile);
				float4 mouth = Mouth(Within(uv, float4( - .3, -0.4, 0.3, -0.1)));
				float4 brow = Brow(Within(uv, float4(0.03, 0.2, 0.4, 0.45)));
				
				col = lerp(col, head, head.a);
				col = lerp(col, eye, eye.a);
				col = lerp(col, mouth, mouth.a);
				col = lerp(col, brow, brow.a);
				
				
				return pow(col, 2.2);
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float2 m = _MousePos - 0.5;
				float smile = 0.5;//cos(_Time.y) * 0.5 + 0.5;
				return Smiley(uv, m, smile);
			}
			ENDCG
			
		}
	}
}
