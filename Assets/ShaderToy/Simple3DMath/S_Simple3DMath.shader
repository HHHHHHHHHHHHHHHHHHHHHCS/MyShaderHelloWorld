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
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float3 ro = float3(0.0, 0.0, -2.0);
				float3 rd = float3(uv.x, uv.y, 0) - ro;
				
				float3 p = float3(sin(_Time.y), 0.0, 1.0 + cos(_Time.y));
				float d = DistLine(ro, rd, p);
				
				d = smoothstep(0.1, 0.09, d);
				
				return pow(d, 2.2);
			}
			ENDCG
			
		}
	}
}
