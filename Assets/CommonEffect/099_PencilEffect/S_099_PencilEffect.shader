Shader "CommonEffect/S_099_PencilEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_GradThresh ("Gradiant Threshold", Range(0.000001, 0.01)) = 0.01
		_ColorThreshold ("Color Threshold", Range(0.0, 1.0)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			
			float _GradThresh;
			float _ColorThreshold;
			float _Intensity;
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 screenuv: TEXCOORD0;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screenuv = ComputeScreenPos(o.pos);
				return o;
			}
			
			#define PI2 6.283185307179559
			#define STEP 2.0
			#define RANGE 16.0
			#define ANGLENUM 4.0
			#define GRADTHRESH 0.01
			#define SENSITIVITY 10.0
			
			inline float4 getCol(float2 pos)
			{
				return tex2D(_MainTex, pos / _ScreenParams.xy);
			}
			
			inline float getVal(float2 pos)
			{
				float4 c = getCol(pos);
				return dot(c.xyz, float3(0.2126, 0.7152, 0.0722));
			}
			
			inline float2 getGrad(float2 pos, float delta)
			{
				float2 d = float2(delta, 0.0);
				return float2(getVal(pos + d.xy) - getVal(pos - d.xy), getVal(pos + d.yx) - getVal(pos - d.yx)) / delta / 2.0;
			}
			
			inline void pR(inout float2 p, float a)
			{
				p = cos(a) * p + sin(a) * float2(p.y, -p.x);
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float2 screenuv = i.screenuv.xy / i.screenuv.w;
				float2 screenPos = float2(i.screenuv.x * _ScreenParams.x, i.screenuv.y * _ScreenParams.y);
				float weight = 1.0;
				
				for (int j = 0; j < ANGLENUM; j ++)
				{
					float2 dir = float2(1.0, 0.0);
					pR(dir, j * PI2 / (2.0 * ANGLENUM));
					
					float2 grad = float2(-dir.y, dir.x);
					for (int i = -RANGE; i <= RANGE; i += STEP)
					{
						float2 b = normalize(dir);
						float2 pos2 = screenPos + float2(b.x, b.y) * i;
						if (pos2.y < 0.0 || pos2.x < 0.0 || pos2.x > _ScreenParams.x || pos2.y > _ScreenParams.y)
						{
							continue;
						}
						
						float2 g = getGrad(pos2, 1.0);
						
						if(sqrt(dot(g, g)) < _GradThresh)
						{
							continue;
						}
						
						weight -= pow(abs(dot(normalize(grad), normalize(g))), SENSITIVITY) / floor((2.0 * RANGE + 1.0) / STEP) / ANGLENUM;
					}
				}
				
				half4 col = getCol(screenPos);
				half4 background = lerp(col, float4(1.0, 1.0, 1.0, 1.0), _ColorThreshold);
				
				return lerp(float4(0.0, 0.0, 0.0, 0.0), background, weight);
			}
			
			ENDCG
			
		}
	}
}
