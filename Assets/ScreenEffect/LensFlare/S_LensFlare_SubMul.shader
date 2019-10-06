Shader "HCS/S_LensFlare_SubMul"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Sub ("Subtract", float) = 0.5
		_Mul ("Multiply", float) = 0.5
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
				float2 uv: TEXCOORD0;
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
			float _Sub;
			float _Mul;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				col = max(col - _Sub, 0);
				col *= _Mul;
				return col;
			}
			
			ENDCG
			
		}
	}
}
