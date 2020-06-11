Shader "WorldNormal/S_WorldNormal"
{
	Properties { }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		Cull Off
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				return float4(i.worldNormal, 1);
			}
			ENDCG
			
		}
	}
}
