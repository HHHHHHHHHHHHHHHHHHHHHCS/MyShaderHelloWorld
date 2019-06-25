Shader "CommonEffect/S_057_Unlit"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			struct a2v
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
			};
			
			half4 _Color;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				return _Color;
			}
			
			ENDCG
			
		}
	}
}
