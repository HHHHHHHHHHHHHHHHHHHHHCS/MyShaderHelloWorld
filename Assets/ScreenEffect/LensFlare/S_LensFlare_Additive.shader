Shader "ScreenEffect/S_LensFlare_Additive"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_MainTex1 ("Texure1", 2D) = "white" { }
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TESSFACTOR0;
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _MainTex1;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv) + tex2D(_MainTex1, i.uv);
				return col;
			}
			
			
			ENDCG
			
		}
	}
}
