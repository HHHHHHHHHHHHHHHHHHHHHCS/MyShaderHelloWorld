Shader "ShaderToy/S_TwistedToroid"
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
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 ro = float3(0, 0, -1);
				float3 lookat = float3(0, 0, 0);
				float zoom = 0.5;
				
				float3 f = normalize(lookat - ro);
				float3 r = normalize(cross(float3(0, 1, 0), f));
				float3 u = cross(f, r);
				float3 c = ro + f * zoom;
				float3 i = c + uv.x * r + uv.y * u;
				float3 rd = normalize(i - ro);
				
				float dS, dO;
				float3 p;
				
				for (int i = 0; i < 100; i ++)
				{
					p = ro + rd * dO;
					dS = - (length(float2(length(p.xz) - 1.0, p.y)) - 0.75);
					if (dS < 0.001)
						break;
					dO += dS;
				}
				
				float3 col = 0;
				
				if(dS < 0.001)
				{
					float x = atan2(p.x, p.z); //-pi to pi
					float y = atan2(length(p.xz) - 1.0, p.y);
					
					float bands = sin(y * 10.0 + x * 20.0);
					float b1 = smoothstep(-0.2, 0.2, bands);

					col += b1;
				}
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
