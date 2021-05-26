Shader "ScreenEffect/S_RadiaBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BlurCenter ("Blur Center", Vector) = (0.5, 0.5,0,0)
		_BlurFactor ("Blur Factor", Float) = 0.01
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
			
			//低精度 提高速度
			#pragma fragmentoption ARB_precision_hint_fastest

			
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
			float _BlurFactor;
			float2 _BlurCenter;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 dir = _BlurCenter.xy - i.uv;
				float4 resColor = 0;
				for (int j = 0; j < 5; ++ j)
				{
					//避免翻转用
					float len = min(_BlurFactor * j, 1.0);
					float2 uv = saturate(i.uv + len * dir);
					resColor += tex2D(_MainTex, uv);
				}
				resColor *= 0.2;
				
				return resColor;
			}
			ENDCG
			
		}
	}
}
