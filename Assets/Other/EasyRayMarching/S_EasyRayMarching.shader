Shader "EasyRayMarching/S_EasyRayMarching"
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
			
			#define MAX_STEPS 100
			#define MAX_DIST 100
			#define SURF_DIST 1e-2
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 ro: TEXCOORD1;
				float3 hitPos: TEXCOORD2;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.ro = mul(unity_WorldToObject, _WorldSpaceCameraPos);
				o.hitPos = v.vertex;
				return o;
			}
			
			float GetDist(float3 p)
			{
				float d = length(p) - 0.5;
				
				d = length(float2(length(p.xy) - 0.5, p.z)) - 0.1;
				d = length(float2(length(p.xz) - 0.5, p.y)) - 0.1;
				
				return d;
			}
			
			float3 GetNormal(float3 p)
			{
				float2 offset = float2(1e-2, 0);
				float3 n = GetDist(p).xxx - float3(
					GetDist(p - offset.xyy),
					GetDist(p - offset.yxy),
					GetDist(p - offset.yyx)
				);
				return normalize(n);
			}
			
			float Raymarch(float3 ro, float3 rd)
			{
				float dO = 0;
				float dS;
				for (int i = 0; i < MAX_STEPS; ++ i)
				{
					float3 p = ro + dO * rd;
					dS = GetDist(p);
					dO += dS;
					
					if (dS < SURF_DIST || dO > MAX_DIST)
						break;
				}
				
				return dO;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = i.uv - 0.5;
				
				float3 ro = i.ro;//float3(0, 0, -3);
				float3 rd = normalize(i.hitPos - ro);//normalize(float3(uv.x, uv.y, 1));
				
				float d = Raymarch(ro, rd);
				float4 texCol = tex2D(_MainTex, i.uv);
				float4 col = 0;
				float m = dot(uv, uv);
				float lerpVal = smoothstep(.1, .2, m);
				if (d < MAX_DIST)
				{
					float3 p = ro + rd * d;
					float3 n = GetNormal(p);
					col.rgb = n;
				}
				else if(lerpVal < 0.001)
				{
					discard;
				}
				
				col = lerp(col, texCol, lerpVal) ;
				
				return col;
			}
			ENDCG
			
		}
	}
}
