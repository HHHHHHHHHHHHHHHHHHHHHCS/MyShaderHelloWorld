Shader "My/S_SimpleRayMarching"
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
			#include "DistanceFunctions.cginc"
			
			sampler2D _MainTex;
			//Setup
			sampler2D _CameraDepthTexture;
			float4x4 _CamFrustum, _CamToWorld;
			float _Accuracy, _MaxIterations, _MaxDistance;
			//light
			float3 _LightCol;
			float3 _LightDir;
			float _LightIntensity;
			//shadow
			float4 _ShadowData;
			//AO
			float3 _AOData;
			//sphere
			float4 _Spheres[100];
			int _SpheresNum;
			float4 _SpheresColor;
			float _SphereSmooth;
			
			
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
			
			float4 DistanceField(float3 p)
			{
				float4 combines;
				combines = float4(_SpheresColor.rgb, SDSphere(p - _Spheres[0].xyz, _Spheres[0].w));
				for (int i = 1; i < _SpheresNum; i ++)
				{
					float4 sphereAdd = float4(_SpheresColor.rgb, SDSphere(p - _Spheres[i].xyz, _Spheres[i].w));
					combines = OpUS(combines, sphereAdd, _SphereSmooth);
				}
				return combines;
			}
			
			float3 GetNormal(float3 p)
			{
				const float2 offset = float2(0.001f, 0.0f);
				float3 n = float3(
					DistanceField(p + offset.xyy).w - DistanceField(p - offset.xyy).w,
					DistanceField(p + offset.yxy).w - DistanceField(p - offset.yxy).w,
					DistanceField(p + offset.yyx).w - DistanceField(p - offset.yyx).w
				);
				return normalize(n);
			}
			
			float HardShadow(float3 ro, float3 rd, float mint, float maxt)
			{
				for (float t = mint; t < maxt; )
				{
					float h = DistanceField(ro + rd * t).w;
					if (h < 0.001)
					{
						return 0.0;
					}
					t += h;
				}
				return 1.0;
			}
			
			float SoftShadow(float3 ro, float3 rd, float mint, float maxt, float k)
			{
				float result = 1.0;
				for (float t = mint; t < maxt; )
				{
					float h = DistanceField(ro + rd * t).w;
					if(h < 0.001)
					{
						return 0.0;
					}
					result = min(result, k * h / t);
					t += h;
				}
				return result;
			}
			
			float AmbientOcclusion(float3 p, float3 n)
			{
				float aoStepSize = _AOData.x;
				float aoInterations = _AOData.y;
				float aoIntensity = _AOData.z;
				
				float step = aoStepSize;
				float ao = 0.0;
				float dist;
				for (int i = 0; i < aoInterations; ++ i)
				{
					dist = step * i;
					ao += max(0.0f, (dist - DistanceField(p + n * dist).w) / dist);
				}
				return(1.0f - ao * aoIntensity);
			}
			
			RayHit RayMarching(Ray ray, float depth, int maxInterations, int maxDistance, int atten)
			{
				RayHit hit = CreateRayHit();
				float t = 0;
				for (int i = 0; i < maxInterations; i ++)
				{
					if(t > maxDistance || t >= depth)
					{
						hit.position = float4(0, 0, 0, 0);
						break;
					}
					
					float3 p = ray.origin + ray.direction * t;
					float4 d = DistanceField(p);
					
					if(d.w < _Accuracy)
					{
						hit.position = float4(p, 1.0f);
						hit.normal = GetNormal(p);
						hit.color = d.rgb / atten;
						break;
					}
					
					t += d.w;
				}
				return hit;
			}
			
			float3 Shading(inout Ray ray, RayHit hit, float3 col)
			{
				float3 light = (_LightCol * dot(-_LightDir, hit.normal) * 0.5 + 0.5) * _LightIntensity;
				
				
				float shadowDistance = _ShadowData.x;
				float shadowIntensity = _ShadowData.y;
				float softShadowPenumbra = _ShadowData.z;
				bool softShadow = _ShadowData.w;
				float shadow;
				if(softShadow)
				{
					shadow = SoftShadow(hit.position.xyz, -_LightDir, 0.1, shadowDistance, softShadowPenumbra) * 0.5 + 0.5;
				}
				else
				{
					shadow = HardShadow(hit.position.xyz, -_LightDir, 0.1, shadowDistance) * 0.5 + 0.5;
				}
				shadow = max(0.0, pow(shadow, shadowIntensity));
				
				float ao = AmbientOcclusion(hit.position.xyz, hit.normal);
				
				return float3(hit.color * light) * shadow * ao;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
				depth *= length(i.ray.xyz);
				Ray ray = CreateRay(_WorldSpaceCameraPos, normalize(i.ray.xyz));
				RayHit hit;
				float4 result = 0;
				hit = RayMarching(ray, depth, _MaxIterations, _MaxDistance, 1);
				if(hit.position.w == 1)
				{
					float3 col = Shading(ray, hit, col);
					result = float4(col, 1);
				}
				
				return result;
			}
			
			ENDCG
			
		}
	}
}
