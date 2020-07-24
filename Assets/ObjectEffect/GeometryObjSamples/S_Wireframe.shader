Shader "ObjectEffect/S_Wireframe"
{
	Properties
	{
		_Color ("Color", Color) = (0, 1, 1, 1)
		[Toggle]_Divide ("Divide", float) = 0
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
			#pragma shader_feature _DIVIDE_ON
			
			#include "UnityCG.cginc"
			
			struct v2g
			{
				float4 pos: POSITION;
			};
			
			struct g2f
			{
				float4 pos: SV_POSITION;
			};
			
			float4 _Color;
			
			v2g vert(appdata_base v)
			{
				v2g o = (v2g)0;
				o.pos = v.vertex;
				return o;
			}
			
			#ifdef _DIVIDE_ON
				[maxvertexcount(10)]
			#else
				[maxvertexcount(4)]
			#endif
			
			void geom(triangle v2g p[3], inout LineStream < g2f > lineStream)
			{
				g2f r[3];
				
				r[0] = (g2f) 0;
				r[0].pos = UnityObjectToClipPos(p[0].pos);
				r[1] = (g2f) 0;
				r[1].pos = UnityObjectToClipPos(p[1].pos);
				r[2] = (g2f) 0;
				r[2].pos = UnityObjectToClipPos(p[2].pos);
				
				#ifdef _DIVIDE_ON
					//这里少了一条边  但是LineStream 一笔画并不能完成
					g2f r4 = (g2f)0;
					r4.pos = UnityObjectToClipPos((p[0].pos + p[1].pos + p[2].pos) / 3);
					lineStream.Append(r[1]);
					lineStream.Append(r[2]);
					lineStream.Append(r4);
					lineStream.Append(r[1]);
					lineStream.Append(r[0]);
					lineStream.Append(r4);
				#else
					lineStream.Append(r[0]);
					lineStream.Append(r[1]);
					lineStream.Append(r[2]);
					lineStream.Append(r[0]);
				#endif
			}
			
			
			float4 frag(g2f i): SV_Target
			{
				return _Color;
			}
			ENDCG
			
		}
	}
}
