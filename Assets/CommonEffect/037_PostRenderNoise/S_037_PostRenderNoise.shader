Shader "CommonEffect/S_037_PostRenderNoise"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_SecondaryTex ("Secondary Texture", 2D) = "white" { }
		_OffsetX ("OffsetX", float) = 0.0
		_OffsetY ("OffsetY", float) = 0.0
		_Intensity ("Mask Intensity", Range(0, 1)) = 0.8
		_Color ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
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
				float2 uv2: TEXCOORD1;
			};
			
			half _OffsetX;
			half _OffsetY;
			
			sampler2D _MainTex;
			sampler2D _SecondaryTex;
			half4 _Color;
			half _Intensity;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv2 = v.texcoord + float2(_OffsetX, _OffsetY);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				half4 col2 = tex2D(_SecondaryTex, i.uv2);
				//return lerp(col, _Color, saturate(1 - col2.r - _Intensity));
				return lerp(col, _Color, ceil(saturate(1 - col2.r - _Intensity)));
			}
			
			ENDCG
			
		}
	}
}
