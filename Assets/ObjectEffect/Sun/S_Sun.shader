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
			
			struct a2v
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 scrPos: TEXCOORD0;
			};
			
			sampler2D _Texture0;
			sampler2D _Texture1;
			
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
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
				float2 fragCoord = (i.scrPos.xy / i.scrPos.w) * _ScreenParams.xy;
				
				float freqs[4];
				freqs[0] = tex2D(_Texture1, float2(0.01, 0.25)).x;
				freqs[1] = tex2D(_Texture1, float2(0.07, 0.25)).x;
				freqs[2] = tex2D(_Texture1, float2(0.15, 0.25)).x;
				freqs[3] = tex2D(_Texture1, float2(0.30, 0.25)).x;
				
				float brightness = freqs[1] * 0.25 + freqs[2] * 0.25;
				float radius = 0.24 + brightness * 0.2;
				float invRadius = 1.0 / radius;
				
				float3 orange = float3(0.8, 0.65, 0.3);
				float3 orangeRed = float3(0.8, 0.35, 0.1);
				float time = _Time.y * 0.1;
				float aspect = _ScreenParams.x / _ScreenParams.y;
				float2 uv = fragCoord.xy / _ScreenParams.xy;
				float2 p = uv - float2(0.5, 0.5);
				p.x *= aspect;
				
				float fade = pow(length(2.0 * p), 0.5);
				float fVal1 = 1.0 - fade;
				float fVal2 = 1.0 - fade;
				
				float angle = atan2(p.x, p.y) / 6.2832;
				float dist = length(p);
				float3 coord = float3(angle, dist, time * 0.1);
				
				float newTime1 = abs(SNoise(coord + float3(0.0, -time * (0.35 + brightness * 0.001), time * 0.015), 15.0));
				float newTime2 = abs(SNoise(coord + float3(0.0, -time * (0.15 + brightness * 0.001), time * 0.015), 45.0));
				for (int i = 1; i <= 7; i ++)
				{
					float  power = pow(2.0, float(i + 1));
					fVal1 += (0.5 / power) * SNoise(coord + float3(0.0, -time, time * 0.2), (power * (10.0) * (newTime1 + 1.0)));
					fVal2 += (0.5 / power) * SNoise(coord + float3(0.0, -time, time * 0.2), (power * (25.0) * (newTime2 + 1.0)));
				}
				
				float corona = pow(fVal1 * max(1.1 - fade, 0.0), 2.0) * 50.0;
				corona += pow(fVal2 * max(1.1 - fade, 0.0), 2.0) * 50.0;
				corona *= 1.2 - newTime1;
				
				float3 sphereNormal = float3(0.0, 0.0, 1.0);
				float3 dir = float3(0.0, 0.0, 0.0);
				float3 center = float3(0.5, 0.5, 1.0);
				float3 starSphere = float3(0.0, 0.0, 0.0);
				
				float2 sp = 2.0 * uv - 1.0;
				sp.x *= aspect;
				sp *= (2.0 - brightness);
				float r = dot(sp, sp);
				float f = ((1.0 - sqrt(abs(1.0 - r))) / r) + brightness * 0.5;
				if (dist < radius)
				{
					corona *= pow(dist * invRadius, 24.0);
					float2 newUV = sp.xy * f;
					newUV += float2(time, 0.0);
					
					float3 texSample = tex2D(_Texture0, newUV).rgb;
					float uOff = (texSample.g * brightness * 4.5 + time);
					float2 starUV = newUV + float2(uOff, 0.0);
					starSphere = tex2D(_Texture0, starUV).rgb;
				}
				
				float starGlow = min(max(1.0 - dist * (1.0 - brightness), 0.0), 1.0);
				
				float4 fragColor;
				fragColor.rgb = float3(f * (0.75 + brightness * 0.3) * orange) + starSphere + corona * orange + starGlow * orangeRed;
				fragColor.a = 1;
				
				return fragColor;
			}
			ENDCG
			
		}
	}
}
