Shader "CommonEffect/S_013_FlowMap"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white"{}
		_FlowMap("Flow Map",2D) = "grey"{}
		_Speed("Speed",Range(-1,1)) = 0.2
	}
	SubShader
	{
		Pass
		{
			Tags {"RenderType"="Opaque"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				half4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _FlowMap;
			half _Speed;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 c;
				half3 flowVal = (tex2D(_FlowMap,i.uv)*2-1) * _Speed;

				float dif1 = frac(_Time.y * 0.25 + 0.5);
				float dif2 = frac(_Time.y * 0.25);

				half lerpVal = abs((0.5 - dif1)/0.5);

				half4 col1 = tex2D(_MainTex,i.uv - flowVal.xy * dif1);
				half4 col2 = tex2D(_MainTex,i.uv - flowVal.xy * dif2);

				c = lerp(col1,col2,lerpVal);
				return c;
			}

			ENDCG
		}
	}
}
