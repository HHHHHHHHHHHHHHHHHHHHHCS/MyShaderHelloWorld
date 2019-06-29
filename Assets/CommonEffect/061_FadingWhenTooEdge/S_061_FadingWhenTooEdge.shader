Shader "CommonEffect/S_061_FadingWhenTooEdge"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_Threshold ("Threshold", Range(0.0, 1.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" }
		
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment  frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half2 uv: TEXCOORD0;
				half val: TEXCOORD1;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Threshold;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = mul(UNITY_MATRIX_VP, worldPos);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
				o.val = abs(dot(worldNormal, viewDir));
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				col.a *= step(_Threshold + 0.01, i.val);
				return col;
			}
			
			ENDCG
			
		}
	}
}
