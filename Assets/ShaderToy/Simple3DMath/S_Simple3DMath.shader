Shader "Simple3DMath/S_Simple3DMath"
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
			
			float DistLine(float3 ro, float3 rd, float3 p)
			{
				return length(cross(p - ro, rd)) / length(rd);
			}
			
			float DrawPoint(float3 ro, float3 rd, float3 p)
			{
				float d = DistLine(ro, rd, p);
				d = smoothstep(0.1, 0.09, d);
				return d;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 ro = float3(3.0 * sin(_Time.y), 2.0, -3.0*cos(_Time.y));
				float3 lookat = float3(0.5, 0.5, 0.5);
				
				float zoom = 1.0;
				
				float3 f = normalize(lookat - ro);
				float3 r = cross(float3(0.0, 1.0, 0.0), f);
				float3 u = cross(f, r);
				
				float3 c = ro + f * zoom;
				float3 i = c + uv.x * r + uv.y * u;
				
				float3 rd = i - ro;
				
				float3 p = float3(sin(_Time.y), 0.0, 1.0 + cos(_Time.y));
				
				float d = 0;
				
				d += DrawPoint(ro, rd, float3(0.0, 0.0, 0.0));
				d += DrawPoint(ro, rd, float3(0.0, 0.0, 1.0));
				d += DrawPoint(ro, rd, float3(0.0, 1.0, 0.0));
				d += DrawPoint(ro, rd, float3(0.0, 1.0, 1.0));
				d += DrawPoint(ro, rd, float3(1.0, 0.0, 0.0));
				d += DrawPoint(ro, rd, float3(1.0, 0.0, 1.0));
				d += DrawPoint(ro, rd, float3(1.0, 1.0, 0.0));
				d += DrawPoint(ro, rd, float3(1.0, 1.0, 1.0));
				
				return pow(d, 2.2);
			}
			ENDCG
			
		}
	}
}
