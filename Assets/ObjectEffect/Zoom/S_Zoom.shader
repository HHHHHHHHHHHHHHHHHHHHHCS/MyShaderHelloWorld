Shader "ObjectEffect/S_Zoom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float2 _Pos;
			float _ZoomFactor;
			float _EdgeFactor;
			float _Size;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 scale = float2(_ScreenParams.x / _ScreenParams.y, 1);
				float2 center = _Pos;
				float2 dir = center - i.uv;
				
				float dis = length(dir * scale);
				float atZoomArea = smoothstep(_Size + _EdgeFactor, _Size, dis);
				
				float4 col = tex2D(_MainTex, saturate(i.uv + dir * _ZoomFactor * atZoomArea));
				return col;
			}
			ENDCG
			
		}
	}
}
