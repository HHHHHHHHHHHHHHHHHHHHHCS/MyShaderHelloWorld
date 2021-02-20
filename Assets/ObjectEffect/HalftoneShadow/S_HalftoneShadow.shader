Shader "HalftoneShadow/S_HalftoneShadow"
{
	Properties
	{
		_Tilling ("Tilling", Int) = 10
		_Width ("Width", Range(-1, 1)) = 0
		_Min ("Min", Range(-2, 2)) = 0.7
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
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float3 normalWS: TEXCOORD1;
				float4 vertex: SV_POSITION;
			};
			
			half4 _LightColor0;
			
			
			int _Tilling;
			float _Width;
			float _Min;
			
			float Remap(float t, float oldMin, float oldMax, float newMin, float newMax)
			{
				return(t - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
			}
			
			float2 Remap(float2 t, float oldMin, float oldMax, float newMin, float newMax)
			{
				t.x = Remap(t.x, oldMin, oldMax, newMin, newMax);
				t.y = Remap(t.y, oldMin, oldMax, newMin, newMax);
				return t;
			}
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float2 screenUV = i.vertex.xy / _Tilling;
				screenUV = frac(screenUV);
				//screenUV = Remap(screenUV, 0, 1.0, -0.5, 0.5);
				screenUV = screenUV - 0.5;
				
				float length = dot(screenUV, screenUV);
				
				half4 col = 0;
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half3 lightColor = _LightColor0.rgb;
				float lightAtten = dot(lightDir, normalize(i.normalWS));
				float halfLambert = Remap(lightAtten, 1, _Width, _Min, 2);
				
				float halftone = pow(length, halfLambert);
				
				halftone = round(halftone);
				halftone = saturate(halftone);
				
				
				return half4(halftone.xxx, 1);
			}
			ENDCG
			
		}
	}
}
