Shader "ScreenEffect/S_Commic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_LineTexture ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		
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
			sampler2D _LineTexture;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 srcColor = tex2D(_MainTex, i.uv);
				half4 lineColor = tex2D(_LineTexture, i.uv);
				float lumin = Luminance(srcColor);
				float gray = 0;
				
				if (lumin < 0.1)
				{
					gray = 0;
				}
				else if(lumin < 0.5)
				{
					gray = lineColor.r;
				}
				else
				{
					gray = 1;
				}
				
				half4 grayColor = gray;
				
				return grayColor;
			}
			ENDCG
			
		}
	}
}
