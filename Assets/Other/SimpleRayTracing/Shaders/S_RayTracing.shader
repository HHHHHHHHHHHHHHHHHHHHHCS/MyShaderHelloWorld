Shader "RayTracing/S_RayTracing"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+250" }
		LOD 100
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			const float NoIntersectionT = -1.0;
			const int MaxBounce = 4;
			const float DistanceAttenuationPower = 0.2;
			
			float4 _RefractedColor;
			float4 _ReflectedColor;
			float4 _HDRColor;
			
			float3 _LightPos;
			float3 _LightColor;

			float3 _MagicOrigin;
			sampler2D _MagicTexture;
			float _MagicAlpha;
			
			samplerCUBE _SkyBox;
			
			struct Ray
			{
				float3 origin;
				float3 direction;
			};
			
			struct Material
			{
				float3 ambientColor;
				float3 diffuseColor;
				float3 specularColor;
				float3 refractedColor;
				float3 reflectedColor;
				float reflectiveness; //反射
				float refractiveness; //折射 但是 有反射就不会有折射
				float shinyness; //高光系数
				float texAlpha; //贴图alpha 0.5是分界线
				float3 refractiveIndex; //折射系数
			};
			
			struct Intersection
			{
				float3 position;
				float t;
				float3 normal;
				bool inside;
			};
			
			struct Light
			{
				float3 position;
				float3 color;
			};
			
			struct a2v
			{
				float4 vertex: POSITION;
				fixed3 normal: NORMAL;
				fixed2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos: POSITION;
				fixed2 uv: TEXCOORD0;
				fixed3 vertex: TEXCOORD1;
				float3 ray: TEXCOORD2;
			};
			
			float4 _Vertices[700];
			
			//射线和三角形求交
			//https://blog.csdn.net/qq_22822335/article/details/50930364
			bool IntersectTriangle(float4 ori, float4 dir, float4 v0, float4 v1, float4 v2, inout Intersection intersection)
			{
				float t, u, v;
				
				//E1
				float4 E1 = v1 - v0;
				
				//E2
				float4 E2 = v2 - v0;
				
				//P
				float4 P = float4(cross(dir, E2), 1);
				
				//determinant
				float det = dot(E1, P);
				
				//keep det > 0, modify T accordingly
				float4 T;
				if (det > 0)
				{
					T = ori - v0;
				}
				else
				{
					T = v0 - ori;
					det = -det;
				}
				
				// If determinant is near zero, ray lies in plane of triangle
				if (det < 0.0001f)
					return false;
				
				// Calculate u and make sure u <= 1
				u = dot(T, P);
				if (u < 0.0f || u > det)
					return false;
				
				// Q
				float4 Q = float4(cross(T, E1), 1);
				
				// Calculate v and make sure u + v <= 1
				v = dot(dir, Q);
				if (v < 0.0f || u + v > det)
					return false;
				
				// Calculate t, scale parameters, ray intersects triangle
				t = dot(E2, Q);
				
				float fInvDet = 1.0f / det;
				t *= fInvDet;
				u *= fInvDet;
				v *= fInvDet;
				
				intersection.position = ori + dir * t;//相交的点
				intersection.t = t;//t:length
				intersection.normal = normalize(cross(E1, E2));
				intersection.inside = dot(intersection.normal, dir) > 0;
				
				return true;
			}
			
			//射线和圆求交 a^2>b^2+c^2 类似于三角形的钝角
			bool IntersectSphere(float3 ori, float3 dir, float3 sphereOri, float radius)
			{
				float t0, t1, t;
				
				float3 l = sphereOri - ori;
				float tca = dot(l, dir);
				// if (tca < 0)
				// 	return false;
				float d2 = dot(l, l) - (tca * tca);
				float r2 = radius * radius;
				if (d2 > r2)
					return false;
				return true;
			}
			
			Intersection CreateNoIntersection()
			{
				Intersection intersection;
				intersection.position = float3(0.0, 0.0, 0.0);
				intersection.t = NoIntersectionT;
				intersection.normal = float3(0.0, 0.0, 0.0);
				intersection.inside = false;
				return intersection;
			}
			
			bool HasIntersection(Intersection i)
			{
				return i.t != NoIntersectionT;
			}
			
			float4 GetSkyColor(float3 direction)
			{
				float4 spec_env = texCUBE(_SkyBox, direction);
				return float4(spec_env.xyz, 1);
			}
			
			Material mats[6];
			
			Material GetMaterial(int matIndex)
			{
				Material mat;
				if(matIndex == 0)//Diamond
				{
					mat.ambientColor = float3(1, 1, 1);
					mat.diffuseColor = 1;
					mat.specularColor = 1;
					mat.reflectedColor = 1;
					mat.refractedColor = float3(1, 1, 1);
					mat.reflectiveness = 0;
					mat.refractiveness = 1;
					mat.shinyness = 40;
					mat.texAlpha = 0;
					mat.refractiveIndex = float3(2.407, 2.426, 2.451);
				}
				else if (matIndex == 1)//Floor
				{
					mat.ambientColor = float3(1, 1, 1);
					mat.diffuseColor = 1;
					mat.specularColor = 1;
					mat.reflectedColor = 1;
					mat.refractedColor = 0;
					mat.reflectiveness = 0.5;
					mat.refractiveness = 0;
					mat.shinyness = 40;
					mat.texAlpha = 1;
					mat.refractiveIndex = float3(2.407, 2.426, 2.451);
				}
				else if(matIndex == 2)//Trillion
				{
					mat.ambientColor = float3(1, 1, 1);
					mat.diffuseColor = 1;
					mat.specularColor = 1;
					mat.reflectedColor = 0;
					mat.refractedColor = _RefractedColor;
					mat.reflectiveness = 0;
					mat.refractiveness = 1;
					mat.shinyness = 40;
					mat.texAlpha = 0;
					mat.refractiveIndex = 2;
				}
				else if(matIndex == 3)//Pyramid
				{
					mat.ambientColor = float3(1, 1, 1);
					mat.diffuseColor = 1;
					mat.specularColor = 1;
					mat.reflectedColor = _ReflectedColor;
					mat.refractedColor = 0;
					mat.reflectiveness = 1;
					mat.refractiveness = 0;
					mat.shinyness = 40;
					mat.texAlpha = 0;
					mat.refractiveIndex = 2;
				}
				else if(matIndex == 4)//HDRPyramid
				{
					mat.ambientColor = _HDRColor;
					mat.diffuseColor = 1;
					mat.specularColor = 1;
					mat.reflectedColor = 1;
					mat.refractedColor = 0;
					mat.reflectiveness = 0.1;
					mat.refractiveness = 0;
					mat.shinyness = 40;
					mat.texAlpha = 0;
					mat.refractiveIndex = 2;
				}
				else
				{
					mat = (Material)0;
				}
				return mat;
			}
			
			//求射线和场景最近的交点
			bool HitScene(Ray ray, inout Intersection minIntersection, inout int matIndex, bool inGeometry)
			{
				bool hitAnything = false;
				
				for (int i = 0; i < 700; )
				{
					int length = _Vertices[i + 1].x;
					
					if (length == 0 || _Vertices[i].w == 0)
						break;
					
					float3 sphereOri = _Vertices[i].xyz;
					float radius = _Vertices[i].w;
					
					i += 2;
					
					if(IntersectSphere(ray.origin, ray.direction, sphereOri, radius))
					{
						for (int j = 0; j < length; j += 3)
						{
							Intersection intersection = CreateNoIntersection();
							if(IntersectTriangle(float4(ray.origin, 1), float4(ray.direction, 0),
							float4(_Vertices[i + j].xyz, 1), float4(_Vertices[i + j + 1].xyz, 1), float4(_Vertices[i + j + 2].xyz, 1), intersection)
							&& intersection.t > 0.001)
							{
								hitAnything = true;
								if((!HasIntersection(minIntersection) || intersection.t < minIntersection.t))
								{
									matIndex = _Vertices[i + j].w;
									minIntersection = intersection;
									//判断正反面 是否需要透过去
									if (minIntersection.inside == inGeometry)
										break;
								}
							}
						}
					}
					i += length;
				}
				return hitAnything;
			}
			
			float3 CalcLighting(Ray ray, Intersection intersection, Material material)
			{
				Light light;
				light.position = _LightPos;
				light.color = _LightColor;
				
				float3 color = material.ambientColor;
				float2 uv = intersection.position.xz;
				color = material.texAlpha < 0.5?material.ambientColor: frac((floor(uv.x) + floor(uv.y)) / 2) * 2;
				color += material.texAlpha < 0.5?0: step(0.5, tex2D(_MagicTexture, ((uv - _MagicOrigin.xz) / 5.0 + 0.5))) * _HDRColor * _MagicAlpha;
				float3 lightDir = normalize(light.position - intersection.position);
				float3 eyeDir = normalize(_WorldSpaceCameraPos - intersection.position);
				color += light.color * material.diffuseColor * max(dot(intersection.normal, lightDir), 0.0);
				float3 reflected = normalize(reflect(-lightDir, intersection.normal));
				color += light.color * material.specularColor * pow(max(dot(reflected, eyeDir), 0.0), material.shinyness);
				//距离越远颜色越黑
				color *= min(1.0 / max(pow(length(intersection.position - ray.origin), DistanceAttenuationPower), 0.001), 1.0);
				return color;
			}
			
			float4 TraceRay(Ray ray, float3 channel)
			{
				Ray rayTemp = ray;
				float4 finalColor = 0;
				float4 colorMask = 1;
				bool inGeometry = false;
				
				for (int i = 0; i < 4 && finalColor.a < 0.99; ++ i)
				{
					Intersection  intersection = CreateNoIntersection();
					float4 col;
					int matIndex;
					
					if (HitScene(rayTemp, intersection, matIndex, inGeometry))
					{
						Material mat = GetMaterial(matIndex);
						
						col = float4(CalcLighting(rayTemp, intersection, mat), 1);
						
						float alpha = mat.reflectiveness > 0.0?1 - mat.reflectiveness: 1 - mat.refractiveness;
						
						finalColor += col * alpha * (1 - finalColor.a) * colorMask;
						
						if(mat.reflectiveness != 0)
						{
							colorMask *= float4(mat.reflectedColor, 1);
						}
						else
						{
							colorMask *= float4(mat.refractedColor, 1);
						}
						
						float3 normal = intersection.normal * (intersection.inside? - 1: 1);
						
						rayTemp.origin = intersection.position;
						
						if(mat.reflectiveness != 0)
						{
							rayTemp.direction = reflect(rayTemp.direction, normal.xyz);
						}
						else
						{
							float refractIndex = dot(mat.refractiveIndex, channel);
							
							refractIndex = intersection.inside?refractIndex: 1 / refractIndex;
							
							//refractIndex 是折射系数
							float3 refraction = refract(rayTemp.direction, normal, refractIndex);
							
							//如果折射过低 用反射
							if (dot(refraction, refraction) < 0.0001)
							{
								rayTemp.direction = reflect(rayTemp.direction, normal.xyz);
							}
							else
							{
								rayTemp.direction = refraction;
								inGeometry = !inGeometry;
							}
						}
					}
					else
					{
						break;
					}
				}
				
				float4 bgCol = GetSkyColor(rayTemp.direction) * colorMask;
				
				finalColor.rgb = finalColor.xyz + bgCol * max(0, 1 - finalColor.a);
				
				finalColor.a = 1;
				
				return dot(finalColor, channel);
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.uv = v.uv;
				
				float4 cameraRay = mul(unity_CameraInvProjection, float4(v.uv * 2.0 - 1.0, 1.0, 1.0));
				o.ray = cameraRay.xyz / cameraRay.w;
				o.ray.z *= -1;
				
				return o;
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float4 viewPos = float4(i.ray, 1);
				float4 worldPos = mul(unity_CameraToWorld, viewPos);
				float3 viewDir = normalize(worldPos - _WorldSpaceCameraPos);
				
				float4 origin = float4(_WorldSpaceCameraPos, 1.0);
				float4 dir = float4(viewDir, 0.0);
				
				Ray ray;
				ray.origin = origin.xyz;
				ray.direction = dir.xyz;
				
				float4 frag = 0;
				
				frag.r = TraceRay(ray, float3(1, 0, 0));
				frag.g = TraceRay(ray, float3(0, 1, 0));
				frag.b = TraceRay(ray, float3(0, 0, 1));
				
				return frag;
			}
			
			ENDCG
			
		}
	}
}
