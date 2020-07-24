Shader "Other/S_CloudRayMarching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	
	SubShader
	{
		//No Culling and depth
		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			
			#include "UnityCG.cginc"
			#include "CloudNoise.cginc"
			#include "DistanceFunctions.cginc"
			
			sampler2D _MainTex;
			
			//Setup
			//--------------------------
			sampler2D _CameraDepthTexture;
			float4x4 _CamFrustum, _CamToWorld;
			float3 _LightDir;
			
			//Cloud
			//--------------------------
			//_CloudSmooth  雾的外轮廓
			float _CloudSmooth;
			float4 _CloudRigi[100];
			int _CloudRigiNum;
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 ray: TEXCOORD1;
			};
			
			struct Ray
			{
				float3 origin;
				float3 direction;
			};
			
			struct RayHit
			{
				float4 position;
				float3 normal;
				float3 color;
			};
			
			Ray CreateRay(float3 origin, float3 direction)
			{
				Ray ray;
				ray.origin = origin;
				ray.direction = direction;
				return ray;
			}
			
			RayHit CreateRayHit()
			{
				RayHit hit;
				hit.position = float4(0.0f, 0.0f, 0.0f, 0.0f);
				hit.normal = float3(0.0f, 0.0f, 0.0f);
				hit.color = float3(0.0f, 0.0f, 0.0f);
				return hit;
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				half index = v.vertex.z;
				v.vertex.z = 0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				
				o.ray = _CamFrustum[(int)index].xyz;
				o.ray /= abs(o.ray.z);//z=-1
				o.ray = mul(_CamToWorld, o.ray);
				
				return o;
			}
			
			float DistanceField(float3 p)
			{
				float combines = 0;
				
				if (_CloudRigiNum > 0)
				{
					combines = SDSphere(p - _CloudRigi[0].xyz, _CloudRigi[0].w);
					for (int i = 0; i < _CloudRigiNum; ++ i)
					{
						float cloudAdd = SDSphere(p - _CloudRigi[i].xyz, _CloudRigi[i].w);
						combines = OpIS(combines, cloudAdd, -0.5);
					}
				}
				
				return combines;
			}
			
			float Density(float3 pos, float dist, float cloudSmooth)
			{
				float den = -0.2 - dist * 1.5 + 3.0 * Fractal_Noise(pos);
				den = clamp(den, 0.0, 1.0);
				//tex2Dlod 用 float 代替 vector4
				float size = clamp(tex2Dlod(_NoiseTex, 0.5 * 2.0 + 0.1), 0.4, 0.8);
				float edge = 1.0 - smoothstep(size * cloudSmooth, cloudSmooth, dist);
				edge *= edge;
				den *= edge;
				return den * 1.5;
			}
			
			float3 CalcColor(float den, float dist)
			{
				float3 result = lerp(float3(1.0, 0.9, 0.8 + sin(_Time.y) * 0.1),
				float3(0.5, 0.15, 0.1 + sin(_Time.y) * 0.1), den * den);
				
				float3 colBot = 3.0 * float3(1.0, 0.9, 0.5);
				float3 colTop = 2.0 * float3(0.5, 0.55, 0.55);
				result *= lerp(colBot, colTop, min((dist + 0.5) / 4, 1.0));
				
				return float3(1, 1, 1);//result
			}
			
			float3 RayMarchingCloud(float3 ro, float3 rd, float t, float3 sceneCol, float depth, float cloudSmooth)
			{
				float4 sum = 0;
				float3 pos = ro + rd * t;
				
				for (int t = 0; t < 1024; ++ t)
				//while(true)
				{
					float dist = length(pos - _CloudRigi[0].xyz);
					for (int i = 0; i < _CloudRigiNum; ++ i)
					{
						float cloudAdd = length(pos - _CloudRigi[i].xyz);
						dist = OpIS(dist, cloudAdd, -0.5);
					}
					if (dist > cloudSmooth + 0.01 || sum.a > 0.99 || t > depth)
					{
						break;
					}
					
					float den = Density(pos, dist, cloudSmooth);
					float4 col = float4(CalcColor(den, dist), den);
					col.rgb *= col.a;
					sum = sum + col * (1.0 - sum.a);
					t += max(0.05, 0.02 * t);
					pos = ro + rd * t;
				}
				
				sum = clamp(sum, 0.0, 1.0);
				sceneCol = lerp(sceneCol, sum.xyz, sum.a);
				return sceneCol;
			}
			
			float4 RayMarching(in Ray ray, float3 sceneCol, float depth)
			{
				RayHit bestHit = CreateRayHit();
				float4 result;
				float t = 0;

				for (int i = 0; i < 64; ++ i)
				{
					if(t > 20 || t >= depth)//t>=20 限制可视距离
					{
						bestHit.position = 0;
						result = float4(sceneCol, 0);
						break;
					}
					
					float3 p = ray.origin + ray.direction * t;
					float d = DistanceField(p);
					if (d < 0.01)//限制烟雾只能在球里面
					{
						bestHit.position.w = 1;
						result = float4(RayMarchingCloud(p, ray.direction, d, sceneCol, depth, _CloudSmooth), bestHit.position.w);
						break;
					}
					t += d;
				}
				return result;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
				depth *= length(i.ray.xyz);
				float4 sceneCol = tex2D(_MainTex, i.uv);
				float4 col = 0;
				Ray ray = CreateRay(_WorldSpaceCameraPos, normalize(i.ray.xyz));
				col = RayMarching(ray, sceneCol.xyz, depth);

				return col;
			}
			
			ENDCG
			
		}
	}
}
