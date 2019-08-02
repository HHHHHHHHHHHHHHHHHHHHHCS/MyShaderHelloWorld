Shader "CommonEffect/S_093_Wireframe"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		
		[PowerSlider(3.0)]
		_WireframeVal ("Wireframe Width", Range(0.0, 0.34)) = 0.05
		_FrontColor ("Front Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_BackColor ("Back Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2g
			{
				float4 pos: SV_POSITION;
			};
			
			struct g2f
			{
				float4 pos: SV_POSITION;
				float3 bary: TEXCOORD0;
			};
			
			v2g vert(appdata_base v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream < g2f > triStream)
			{
				g2f o;
				o.pos = IN[0].pos;
				o.bary = float3(1.0, 0, 0);
				triStream.Append(o);
				o.pos = IN[1].pos;
				o.bary = float3(0.0, 0.0, 1.0);
				triStream.Append(o);
				o.pos = IN[2].pos;
				o.bary = float3(0.0, 1.0, 0.0);
				triStream.Append(o);
				triStream.RestartStrip();
			}
			
			float _WireframeVal;
			half4 _BackColor;
			
			half4 frag(g2f i): SV_TARGET
			{
				if (!any(bool3(i.bary.x < _WireframeVal, i.bary.y < _WireframeVal, i.bary.z < _WireframeVal)))
				{
					discard;
				}
				
				return _BackColor;
			}
			
			ENDCG
			
		}
		
		Pass
		{
			Cull Back
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2g
			{
				float4 pos: SV_POSITION;
			};
			
			struct g2f
			{
				float4 pos: SV_POSITION;
				float3 bary: TEXCOORD0;
			};
			
			v2g vert(appdata_base v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream < g2f > triStream)
			{
				g2f o;
				o.pos = IN[0].pos;
				o.bary = float3(1.0, 0, 0);
				triStream.Append(o);
				o.pos = IN[1].pos;
				o.bary = float3(0.0, 0.0, 1.0);
				triStream.Append(o);
				o.pos = IN[2].pos;
				o.bary = float3(0.0, 1.0, 0.0);
				triStream.Append(o);
				triStream.RestartStrip();
			}
			
			float _WireframeVal;
			half4 _FrontColor;
			
			half4 frag(g2f i): SV_TARGET
			{
				if (!any(bool3(i.bary.x < _WireframeVal, i.bary.y < _WireframeVal, i.bary.z < _WireframeVal)))
				{
					discard;
				}
				
				return _FrontColor;
			}
			
			ENDCG
			
		}
	}
}
