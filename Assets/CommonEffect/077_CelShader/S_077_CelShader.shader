Shader "CommonEffect/S_077_CelShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Treshold ("Cel Treshold", Range(1., 20)) = 5.
		_Ambient ("Ambient intensity", Range(0., 0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		
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
				float3 worldNormal: NORMAL;
			};
			
			float _Treshold;
			
			float LightToonShading(float3 normal, float3 lightDir)
			{
				float NDotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
				return floor(NDotL * _Treshold) / (_Treshold - 0.5);
			}
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal.xyz);
				return o;
			}
			
			half4 _LightColor0;
			half _Ambient;
			
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				col.rgb *= saturate(LightToonShading(i.worldNormal, _WorldSpaceLightPos0.xyz) + _Ambient) * _LightColor0.rgb;
				return col;
			}
			
			ENDCG
			
		}
	}
}
