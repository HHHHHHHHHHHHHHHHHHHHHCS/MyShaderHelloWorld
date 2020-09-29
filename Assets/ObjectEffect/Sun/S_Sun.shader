Shader "ObjectEffect/Sun"
{
	Properties
	{
		_Texture0 ("Texture0", 2D) = "white" { }
		_Texture1 ("Texture1", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float2 scrPos: TEXCOORD0;
				float4 pos: SV_POSITION;
			};
			
			sampler2D _Texture0;
			sampler2D _Texture1;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = ComputeScreenPos(o.pos);
				return o;
			}
			
			float SNoise(float3 uv, float res)    // by trisomie21
			{
				const float3 s = float3(1e0, 1e2, 1e4);
				
				uv *= res;
				
				float3 uv0 = floor(fmod(uv, res)) * s;
				float3 uv1 = floor(fmod(uv + float3(1, 1, 1), res)) * s;
				
				float3 f = frac(uv);
				f = f * f * (3.0 - 2.0 * f);
				
				float4 v = float4(uv0.x + uv0.y + uv0.z, uv1.x + uv0.y + uv0.z,
				uv0.x + uv1.y + uv0.z, uv1.x + uv1.y + uv0.z);
				
				float4 r = frac(sin(v * 1e-3) * 1e5);
				float r0 = lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y);
				
				r = frac(sin((v + uv1.z - uv0.z) * 1e-3) * 1e5);
				float r1 = lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y);
				
				return lerp(r0, r1, f.z) * 2. - 1.;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = (i.scrPos.xy / i.scrPos.w) * _ScreenParams.xy;
				
				float freqs[4];
				freqs[0] = tex2D(_Texture0, float2(0.01, 0.25)).x;
			}
			ENDCG
			
		}
	}
}
