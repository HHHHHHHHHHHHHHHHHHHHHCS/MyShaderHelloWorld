Shader "CommonEffect/S_081_QuadsToPyramids"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Factor ("Factor", Range(0, 2.0)) = 0.2
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Cull Off
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			#include "UnityCG.cginc"
			
			struct v2g
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float2 uv: TEXCOORD0;
			};
			
			struct g2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				half4 col: COLOR;
			};
			
			float nrand(float3 pos)
			{
				return frac(sin( dot(float3(pos.x, pos.y, pos.z), float3(12.9898, 78.233, 21345))) * 43758.5453);
			}
			
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2g vert(appdata_base v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = v.normal;
				return o;
			}
			
			float _Factor;
			
			[maxvertexcount(12)]
			void geom(triangle v2g IN[3], inout TriangleStream < g2f > tristream)
			{
				g2f o;
				
				float3 normalFace = normalize(cross(IN[1].vertex - IN[0].vertex, IN[2].vertex - IN[0].vertex));
				//float3 normalFace =(IN[0].normal+IN[1].normal+IN[2].normal)/3;
				
				float edge1 = distance(IN[1].vertex, IN[0].vertex);
				float edge2 = distance(IN[2].vertex, IN[0].vertex);
				float edge3 = distance(IN[2].vertex, IN[1].vertex);
				
				float3 centerPos = (IN[0].vertex + IN[1].vertex) / 2;
				float2 centerTex = (IN[0].uv + IN[1].uv) / 2;
				
				if (step(edge1, edge2) * step(edge3, edge2) == 1.0)
				{
					centerPos = (IN[2].vertex + IN[0].vertex) / 2;
					centerTex = (IN[2].uv + IN[0].uv) / 2;
				}
				else if(step(edge2, edge3) * step(edge1, edge3) == 1.0)
				{
					centerPos = (IN[1].vertex + IN[2].vertex) / 2;
					centerTex = (IN[1].uv + IN[2].uv) / 2;
				}
				
				float4 worldPos = mul(unity_ObjectToWorld, centerPos);
				centerPos += float4(normalFace, 0) * _Factor * (sin(nrand(worldPos) + _Time.w) + 1.001) / 2;
				
				float4 centerClipPos = UnityObjectToClipPos(float4(centerPos, 1));
				
				[unroll]
				for (int i = 0; i < 3; i ++)
				{
					o.pos = UnityObjectToClipPos(IN[i].vertex);
					o.uv = IN[i].uv;
					o.col = half4(0, 0, 0, 1);
					tristream.Append(o);
					
					int inext = (i + 1) % 3;
					o.pos = UnityObjectToClipPos(IN[inext].vertex);
					o.uv = IN[inext].uv;
					o.col = half4(0, 0, 0, 1);
					tristream.Append(o);
					
					o.pos = centerClipPos;
					o.uv = centerTex;
					o.col = half4(1.0, 1.0, 1.0, 1);
					tristream.Append(o);
					
					tristream.RestartStrip();
				}
				
				o.pos = UnityObjectToClipPos(IN[0].vertex);
				o.uv = IN[0].uv;
				o.col = half4(0, 0, 0, 1);
				tristream.Append(o);
				
				o.pos = UnityObjectToClipPos(IN[1].vertex);
				o.uv = IN[1].uv;
				o.col = half4(0, 0, 0, 1);
				tristream.Append(o);
				
				o.pos = UnityObjectToClipPos(IN[2].vertex);
				o.uv = IN[2].uv;
				o.col = half4(0, 0, 0, 1);
				tristream.Append(o);
				
				tristream.RestartStrip();
			}
			
			half4 frag(g2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv) * i.col;
				return col;
			}
			ENDCG
			
		}
	}
}
