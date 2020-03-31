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
			
			RayHit RayMarching(Ray ray, float depth, int maxInterations, int maxDistance, int atten)
			{
				RayHit hit = CreateRayHit();
				float t = 0;
				for (int i = 0; i < maxInterations; i ++)
				{
					if (t > maxDistance || t >= depth)
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
					result = 1;//float4(abs(hit.color/10),1);
				}
				
				return result;
			}
			
			ENDCG
			
		}
	}
}
