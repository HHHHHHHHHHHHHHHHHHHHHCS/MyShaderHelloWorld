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
				const float _sphereRadius = 0.5;
				return SDSphere(p, _sphereRadius);
			}
			
			float3 GetNormal(float3 p)
			{
				const float2 offset = float2(0.001f, 0.0f);
				float3 n = float3(
					DistanceField(p + offset.xyy) - DistanceField(p - offset.xyy),
					DistanceField(p + offset.yxy) - DistanceField(p - offset.yxy),
					DistanceField(p + offset.yyx) - DistanceField(p - offset.yyx)
				);
				return normalize(n);
			}
			
			RayHit RayMarching(Ray ray, float depth)
			{
				const float maxDistance = 99999;

				RayHit hit = CreateRayHit();
				float t = 0;
				for (int i = 0; i < 30; i ++)
				{
					if (t > maxDistance || t >= depth)
					{
						hit.position.w = 0;
						break;
					}
					
					float3 p = ray.origin + ray.direction * t;
					float4 d = DistanceField(p);
					
					if(d.w < 0.01)
					{
						hit.position = float4(p, 1.0f);
						hit.normal = GetNormal(p);
						break;
					}
					
					t += d.w;
				}
				return hit;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				Ray ray = CreateRay(_WorldSpaceCameraPos, normalize(i.ray.xyz));
				return float4(ray.direction, 1.0);
			}
			
			ENDCG
			
		}
	}
}
