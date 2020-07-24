Shader "ScreenEffect/S_OutlineObj"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			
			CGPROGRAM
			
			#pragma target 3.0
			
			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			
			struct a2v
			{
				float4 vertex: POSITION;
				float4 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				//v.vertex.xyz += v.normal.xyz * 0.05;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			
			float4 frag(v2f i): SV_TARGET
			{
				return float4(1, 1, 1, 1);
			}
			
			
			ENDCG
			
		}
	}
}
