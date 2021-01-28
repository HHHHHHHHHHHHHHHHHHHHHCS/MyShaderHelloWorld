Shader "ShaderToy/S_Heart3D"
{
	Properties { }
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
			
			#define QUALITY 1
			#define LOOP_COUNT 2
			
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
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half3 Render(float2 p)
			{
				//camera
				//-----------------------
				float an = 0.1 * _Time.y;
				
				

				return 0;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				half3 col = 0;
				
				
				#if QUALITY > 1
					for (int m = 0; m < LOOP_COUNT; ++ m)
					{
						for (int n = 0; n < LOOP_COUNT; ++ n)
						{
							//0~1 像素 * 2 = 0~2个像素
							float2 px = 2 * float2(m, n) / LOOP_COUNT / _ScreenParams.y;
							
							col += Render(uv + px);
						}
					}
					col /= float(LOOP_COUNT * LOOP_COUNT);
				#else
					col = Render(uv);
				#endif
				
				return half4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
