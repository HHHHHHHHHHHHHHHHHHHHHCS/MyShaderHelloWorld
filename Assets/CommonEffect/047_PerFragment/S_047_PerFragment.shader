Shader "CommonEffect/S_047_PerFragment"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = normalize(mul(unity_ObjectToWorld, v.normal).xyz);
				return o ;
			}
			
			half4 _LightColor0;
			
			half4 frag(v2f i): SV_TARGET
			{
				float dif = max(0.0, dot(i.normal, normalize(_WorldSpaceLightPos0.xyz)));
				half4 col = tex2D(_MainTex, i.uv);
				return half4(col.rgb * dif * _LightColor0.rgb, 1);
			}
			
			ENDCG
			
		}
	}
}
