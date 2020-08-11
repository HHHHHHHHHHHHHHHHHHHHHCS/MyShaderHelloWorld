﻿Shader "ShaderToy/S_RainScreen"
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
			
			struct Ray
			{
				float3 o;
				float3 d;
			};
			
			Ray GetRay(float2 uv, float3 camPos, float3 lookat, float zoom)
			{
				Ray ray;
				ray.o = camPos;
				float3 f = normalize(lookat - camPos);
				float3 r = cross(float3(0, 1, 0), f);
				float3 u = cross(f, r);
				float3 c = ray.o + f * zoom;
				
				float3 i = c + uv.x * r + uv.y * u;
				
				ray.d = normalize(i - ray.o);
				
				return ray;
			}
			
			float3 ClosetPoint(Ray r, float3 p)
			{
				return r.o + max(0.0, dot(p - r.o, r.d)) * r.d;
			}
			
			float3 DistRay(Ray r, float3 p)
			{
				return length(p - ClosetPoint(r, p));
			}
			
			float Bokeh(Ray r, float3 p, float size, float blur)
			{
				float d = DistRay(r, p);
				
				float c = smoothstep(size, size * (1.0 - blur), d);
				
				c *= lerp(0.6, 1.0, smoothstep(size * 0.8, size, d));
				
				return c;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f input): SV_Target
			{
				float2 uv = input.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				float t = _Time.x;
				
				float3 col = float3(0, 0, 0);
				
				float3 camPos = float3(0, 0.2, 0);
				float3 lookat = float3(0, 0.2, 1.0);
				
				Ray r = GetRay(uv, camPos, lookat, 2.0);
				
				float3 p = float3(0, 0, 5.0);
				
				float c = Bokeh(r, p, 0.3, 0.1);
				
				col = float3(1.0, 0.7, 0.3) * c;
				
				return float4(pow(col, 2.2), 1.0);
			}
			ENDCG
			
		}
	}
}
