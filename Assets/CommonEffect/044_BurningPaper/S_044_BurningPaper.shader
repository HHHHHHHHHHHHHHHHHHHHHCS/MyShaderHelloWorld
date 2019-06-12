Shader "CommonEffect/S_044_BurningPaper"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_DissolveTex ("Dissolution texture", 2D) = "gray" { }
		_Threshold ("Threshold", Range(0, 1.1)) = 0
	}
	SubShader
	{
		Pass
		{
			Tags { "Queue" = "Geometry" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DissolveTex;
			float _Threshold;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 c = tex2D(_MainTex, i.uv);
				half val = 1 - tex2D(_DissolveTex, i.uv).r;
				if (val < _Threshold - 0.04)
				{
					discard;
				}
				
				fixed b = step(val, _Threshold - 0.0001);
				half4 temp = half4(lerp(1, 0, 1 - saturate(abs(_Threshold - val) / 0.04)), 0, 0, 1);
				return lerp(c, c * temp, b);
			}
			
			
			ENDCG
			
		}
	}
}
