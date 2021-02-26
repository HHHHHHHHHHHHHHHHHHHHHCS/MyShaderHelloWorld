Shader "ObjectEffect/S_HexGridRings"
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
			};
			
			struct v2f
			{
				float4 hclipPos: SV_POSITION;
				float4 wPos: TEXCOORD0;
			};
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.hclipPos = mul(UNITY_MATRIX_VP, o.wPos);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				
				
				
				return 0;
			}
			ENDCG
			
		}
	}
}
