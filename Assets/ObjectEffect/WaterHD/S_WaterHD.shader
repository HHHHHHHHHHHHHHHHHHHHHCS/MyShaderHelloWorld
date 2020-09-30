Shader "ObjectEffect/S_WaterHD"
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
			
			struct a2v
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 scrPos: TEXCOORD0;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = tex2D(_MainTex, i.scrPos);
				return col;
			}
			ENDCG
			
		}
	}
}
