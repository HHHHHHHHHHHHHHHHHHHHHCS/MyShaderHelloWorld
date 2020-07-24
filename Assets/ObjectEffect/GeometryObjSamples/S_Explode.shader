Shader "ObjectEffect/S_Explode"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_TAmount ("T Amount", float) = 0.2
		_DeadDir ("Vector Value", Vector) = (1, 1, 1, 1)
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
			#pragma geometry geom
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2g
			{
				float2 uv: TEXCOORD0;
				float4 vertex: POSITION;
			};
			
			struct g2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _TAmount;
			float4 _DeadDir;
			
			v2g vert(appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float4 Explode(float4 position, float3 normal)
			{
				
				float3 s = 0.5 * 3.0 * _TAmount * _TAmount * (float3(2, 1, 0) + normal + _DeadDir);
				return position + float4(s, 0.0);
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream < g2f > triangleStream)
			{
				float3 v1 = IN[1].vertex - IN[0].vertex;
				float3 v2 = IN[2].vertex - IN[0].vertex;
				
				float3 norm = normalize(cross(v1, v2));
				
				for (int i = 0; i < 3; ++ i)
				{
					g2f o;
					o.vertex = Explode(IN[i].vertex, norm);
					o.vertex = UnityObjectToClipPos(o.vertex);
					o.uv = IN[i].uv;
					triangleStream.Append(o);
				}
				//triangleStream.RestartStrip();
			}
			
			[maxvertexcount(1)]
			void geom1(triangle v2g IN[3], inout PointStream < g2f > pointStream)
			{
				
				g2f o;
				float3 v1 = IN[1].vertex - IN[0].vertex;
				float3 v2 = IN[2].vertex - IN[0].vertex;
				
				float3 norm = normalize(cross(v1, v2));
				
				o.vertex = Explode(IN[0].vertex, norm);
				o.vertex = UnityObjectToClipPos(o.vertex);
				o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
				pointStream.Append(o);
				pointStream.RestartStrip();
			}
			
			
			
			float4 frag(g2f i): SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
			
		}
	}
}
