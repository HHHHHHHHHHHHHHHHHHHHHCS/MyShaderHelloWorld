﻿Shader "ObjectEffect/S_WireframeDotted"
{
	Properties
	{
		_Color ("Color", Color) = (0, 1, 1, 1)
		_SolidLength ("Solid Lenght", float) = 1
		_SolidScale ("Solid Scale", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			#include "UnityCG.cginc"
			
			struct v2g
			{
				float4 pos: POSITION;
			};
			
			
			struct g2f
			{
				float4 pos: SV_POSITION;
				float4 p: TEXCOORD1;
			};
			
			
			float4 _Color;
			float _SolidScale, _SolidLength;
			
			v2g vert(appdata_base v)
			{
				v2g o = (v2g)0;
				o.pos = v.vertex;
				return o;
			}
			
			void AddInStream(g2f r0, g2f r1, inout LineStream < g2f > lineStream)
			{
				float4 srcPos0 = ComputeScreenPos(r0.pos);
				srcPos0.xy /= srcPos0.w;
				float4 srcPos1 = ComputeScreenPos(r1.pos);
				srcPos1.xy /= srcPos1.w;
				float dist = length(srcPos0.xy - srcPos1.xy);
				if (srcPos0.x > srcPos1.x || srcPos0.y > srcPos1.y)
				{
					r0.p = 0;
					r1.p = dist;
					lineStream.Append(r0);
					lineStream.Append(r1);
				}
				else
				{
					r0.p = dist;
					r1.p = 0;
					lineStream.Append(r1);
					lineStream.Append(r0);
				}
			}
			
			[maxvertexcount(4)]
			void geom(triangle v2g p[3], inout LineStream < g2f > lineStream)
			{
				g2f r[3];
				r[0] = (g2f)0;
				r[0].pos = UnityObjectToClipPos(p[0].pos);
				r[1] = (g2f)0;
				r[1].pos = UnityObjectToClipPos(p[1].pos);
				r[2] = (g2f)0;
				r[2].pos = UnityObjectToClipPos(p[2].pos);
				AddInStream(r[0], r[1], lineStream);
				AddInStream(r[1], r[2], lineStream);
				AddInStream(r[0], r[2], lineStream);
			}
			
			float4 frag(g2f i): SV_Target
			{
				clip(fmod(i.p * 100, _SolidLength) - _SolidLength * (1 - _SolidScale));
				return _Color;
			}
			
			
			ENDCG
			
		}
	}
}
