Shader "CommonEffect/S_053_VertexID"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Val1 ("Value 1", Range(1, 50)) = 2
		_Val2 ("Value 2", Range(1, 50)) = 7
		_Val3 ("Value 3", Range(1, 50)) = 5
		_Color1 ("Color 1", Color) = (1, 1, 1, 1)
		_Color2 ("Color 2", Color) = (1, 1, 1, 1)
		_Color3 ("Color 3", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				half4 col: COLOR0;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Val1;
			float _Val2;
			float _Val3;
			half4 _Color1;
			half4 _Color2;
			half4 _Color3;
			
			v2f vert(appdata_base v, uint id: SV_VERTEXID)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.col = half4(1, 1, 1, 1);
				
				if (fmod(id, floor(_Val1)) == 0)
					o.col *= _Color1;
				if(fmod(id, floor(_Val2)) == 0)
					o.col *= _Color2;
				if(fmod(id, floor(_Val3)) == 0)
					o.col *= _Color3;
				
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				return i.col * col;
			}
			
			ENDCG
			
		}
	}
}
