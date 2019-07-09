Shader "CommonEffect/S_073_TriangleMosaic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_TileNumX ("Tile number along X", float) = 0
		_TileNumY ("Tile number along Y", float) = 0
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
				float4 screenUV: TEXCOORD1;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screenUV = ComputeScreenPos(o.pos);
				return o;
			}
			
			float _TileNumX;
			float _TileNumY;
			sampler2D _MainTex;
			
			
			half4 frag(v2f i): SV_TARGET
			{
				float2 uv = i.screenUV.xy / i.screenUV.w;
				float2 tileNum = float2(_TileNumX, _TileNumY);
				float2 uv2 = floor(uv * tileNum) / tileNum;
				uv -= uv2;
				uv *= tileNum;
				
				half4 col = tex2D(_MainTex, uv2 + float2(step(1- uv.y, uv.x) / (2.0 * _TileNumX), step(uv.x, uv.y) / (2.0 * _TileNumY)));
				
				return col;
			}
			
			
			
			ENDCG
			
		}
	}
}
