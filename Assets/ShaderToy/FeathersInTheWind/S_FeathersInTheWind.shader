Shader "ShaderToy/S_FeathersInTheWind"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
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
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float2x2 Rot(float a)
			{
				float s, c;
				sincos(a, s, c);
				return float2x2(c, -s, s, c);
			}
			
			float3 Transform(float3 p, float angle)
			{
				p.xz = mul(Rot(angle), p.xz);
				p.xy = mul(Rot(angle * 0.7), p.xy);
				
				return p;
			}
			
			float Feather(float2 p)
			{
				float d = length(p - float2(0, clamp(p.y, -0.3, 0.3)));
				float r = lerp(0.1, 0.01, smoothstep(-0.3, 0.3, p.y));
				float m = smoothstep(0.01, 0.0, d - r);
				
				float side = sign(p.x);
				float x = 0.9 * abs(p.x) / r;
				float wave = (1.0 - x) * sqrt(x) + x * (1.0 - sqrt(1.0 - x));
				float y = (p.y - wave * 0.2) * 40.0 + side * 56.0;
				
				float id = floor(y + 20.0);
				float n = frac(sin(id * 564.32) * 763.0);//random per strand number
				float shade = lerp(0.1, 1.0, n);
				
				float strand = smoothstep(0.1, 0.0, abs(frac(y) - 0.5) - 0.3) ;
				float strandLength = lerp(0.7, 1.0, frac(n * 34.0));
				strand *= smoothstep(0.1, 0.0, x - strandLength);
				
				d = length(p - float2(0, clamp(p.y, -0.45, 0.1)));
				float stem = smoothstep(0.01, 0.0, d + p.y * 0.025);
				
				return max(strand * m * shade, stem);
			}
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float4 col = 0;
				
				// uv -= float2(0, -0.45);
				// float d = length(uv);
				// uv = mul(Rot(sin(_Time.y) * d), uv);
				// uv += float2(0, -0.45);
				
				//col += Feather(uv);
				
				float3 ro = float3(0, 0, -3);
				float3 rd = normalize(float3(uv, 1));
				float3 pos = float3(0, 0, 0);
				
				float angle = _Time.y;
				float t = dot(pos - ro, rd);
				float3 p = ro + rd * t;
				
				float y = length(pos - p);
				
				if (y < 1.0)
				{
					float x = sqrt(1.0 - y);
					
					float3 pF = ro + rd * (t - x) - pos;//前面 当作球渲染
					pF = Transform(pF, angle);
					//球坐标反算uv坐标
					float2 uvF = float2(atan2(pF.x, pF.z), pF.y); //[-pi,pi]  [-1,1]
					uvF *= float2(0.25, 0.5);//羽毛的缩放
					float f = Feather(uvF);
					float4 front = f;
					
					float3 pB = ro + rd * (t + x) - pos;//后面 当作球渲染
					pB = Transform(pB, angle);
					float2 uvB = float2(atan2(pB.x, pB.z), pB.y); //[-pi,pi]  [-1,1]
					uvB *= float2(0.25, 0.5);
					float b = Feather(uvB);
					float4 back = b;
					
					col += lerp(back, front, front.a);
				}
				
				return pow(col, 2.2);//float4(pow(col, 2.2), 1);
			}
			ENDCG
			
		}
	}
}
