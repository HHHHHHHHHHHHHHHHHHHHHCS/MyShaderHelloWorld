Shader "HCS/S_Heart"
{
	Properties
	{
		_BackgroundColor ("Background Color", Color) = (1.0, 0.8, 0.7, 1.0)
		_HeartColor ("Heart Color", Color) = (1.0, 0.5, 0.3, 1.0)
		_ChangeColor ("Change Color", Color) = (1, 1, 1, 1)
		_Eccentricity ("Eccentricity", Range(0, 0.5)) = 0.25
		_Blur ("Edge Blur", Range(0, 0.3)) = 0.01
		_Duration ("Duration", Range(0, 10.0)) = 1.5
	}
	
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _ChangeColor;
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag(v2f i): SV_TARGET
			{
				float2 p = 2 * (i.uv + float2(-0.5, -0.5));
				p.y -= 0.25;
				float3 bcol = float3(1.0, 0.8, 0.7 - 0.07 * p.y) * (1.0 - 0.25 * length(p));
				
				float tt = fmod(_Time.y, 1.5) / 1.5;
				float ss = pow(tt, 0.2) * 0.5 + 0.5;
				ss = 1.0 + ss * 0.5 * sin(tt * 6.2831 * 3.0 + p.y + 0.5) * exp(-tt * 4.0);
				p *= float2(0.5, 1.5) + ss * float2(0.5, -0.5);
				
				float a, r, h;
				
				float t_frac = frac(_Time.y);
				float offset = abs(sin(t_frac));
				
				if (p.x > 0)
				{
					p.x -= offset;
					p.y += offset;
					a = atan2(p.x, p.y) / 3.1415926;
					h = a;
				}
				else
				{
					p.x += offset;
					p.y += offset;
					a = atan2(p.x, p.y) / 3.1415926;
					h = -a;
				}
				
				r = length(p);
				float d = (13.0 * h - 22.0 * h * h + 10.0 * h * h * h) / (6.0 - 5.0 * h * (1 - t_frac));
				
				float s = 1.0 - 0.5 * clamp(r / d, 0.0, 1.0);
				s = 0.75 + 0.75 * p.x;
				s *= 1.0 - 0.25 * r;
				s = 0.5 + 0.6 * s;
				s *= 0.5 + 0.5 * pow(1.0 - clamp(r / d, 0.0, 1.0), 0.1);
				
				float3 hcol = float3(1.0, 0.5 * r, 0.3) * s;
				
				
				bcol = lerp(bcol, fixed4(1, 1, 1, 1), t_frac);
				hcol = lerp(hcol, _ChangeColor, t_frac);
				float temp = smoothstep(-0.01, 0.01, d - r);
				
				float3 col = lerp(bcol, hcol, temp);
				
				
				return fixed4(col, 1);
			}
			
			ENDCG
			
		}
	}
	FallBack off
}