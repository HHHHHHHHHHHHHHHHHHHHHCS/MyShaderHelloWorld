Shader "ShaderToy/S_Birthday"
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
			
			
			struct Ray
			{
				float3 o;
				float3 d;
			};
			
			struct Camera
			{
				float3 p;			// the position of the camera
				float3 forward;	// the camera forward vector
				float3 left;		// the camera left vector
				float3 up;		// the camera up vector
				
				float3 center;	// the center of the screen, in world coords
				float3 i;			// where the current ray intersects the screen, in world coords
				Ray ray;		// the current ray: from cam pos, through current uv projected on screen
				float3 lookAt;	// the lookat point
				float zoom;		// the zoom factor
			};
			
			struct Mat
			{
				// data type used to pass the various bits of information used to shade a de object
				float d;	// distance to the object
				float b;	// bump
				float m; 	// material
				float f;	// flame
				float w;	// distance to wick
				float fd;	// distance to flame
				float t;
				float s; // closest flame pass
				float sd;
				float2 uv;
				// shading parameters
				float3 pos;		// the world-space coordinate of the fragment
				float3 nor;		// the world-space normal of the fragment
				float fresnel;
			};
			
			//处理重复数量 时候 uv的用的
			struct RC
			{
				// data type used to handle a repeated coordinate
				float3 id;	// holds the floor'ed coordinate of each cell. Used to identify the cell.
				float3 h;		// half of the size of the cell
				float3 p;		// the repeated coordinate
			};
			
			#define MAX_STEPS 100
			#define MIN_DISTANCE 0.1
			#define MAX_DISTANCE 10.
			#define RAY_PRECISION 0.01
			
			const float3 lf = float3(1., 0., 0.);
			const float3 up = float3(0., 1., 0.);
			const float3 fw = float3(0., 0., 1.);
			
			const float halfpi = 1.570796326794896619;
			const float pi = 3.141592653589793238;
			const float twopi = 6.283185307179586;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float2 _MousePos;
			
			Camera cam;
			
			//Noise
			//-----------------------------
			inline float N(float x)
			{
				return frac(sin(x) * 5346.1764);
			}
			inline float N2(float x, float y)
			{
				return N(x + y * 23414.324);
			}
			inline float LN(float x)
			{
				return lerp(N(floor(x)), N(floor(x + 1.)), frac(x));
			}
			
			inline float N21(float2 p)
			{
				float3 a = frac(float3(p.xyx) * float3(213.897, 653.453, 253.098));
				a += dot(a, a.yzx + 79.76);
				return frac((a.x + a.y) * a.z);
			}
			//End Noise
			
			//Camera
			//---------------------------
			void CameraSetup(float2 uv, float3 position, float3 lookAt, float zoom)
			{
				cam.p = position;
				cam.lookAt = lookAt;
				cam.forward = normalize(cam.lookAt - cam.p);
				cam.left = cross(up, cam.forward);
				cam.up = cross(cam.forward, cam.left);
				cam.zoom = zoom;
				
				cam.center = cam.p + cam.forward * cam.zoom;
				cam.i = cam.center + cam.left * uv.x + cam.up * uv.y;
				
				cam.ray.o = cam.p;						// ray origin = camera position
				cam.ray.d = normalize(cam.i - cam.p);	// ray direction is the vector from the cam pos through the point on the imaginary screen
			}
			
			void InitCamera(float2 uv, float m, float t)
			{
				float turn = (0.1 - m.x) * twopi + t * 0.2; //鼠标的移动 和 时间的移动
				float s = sin(turn);
				float c = cos(turn);
				float3x3 rotX = float3x3(c, 0., s,
				0., 1., 0.,
				s, 0., -c);
				
				
				float3 lookAt = float3(0., .8, 0.);//朝向的点
				float dist = 6.;//z距离
				float y = .4;//INVERTMOUSE*dist*sin((m.y*pi)); //摄像机高度
				float3 pos = float3(0., y, -dist);//摄像机的位置
				pos = mul(pos , rotX);//移动摄像机矩阵
				
				CameraSetup(uv, pos, lookAt, 3.0);
			}
			
			//End Camera
			
			
			
			
			//RayMarching
			//-------------------
			
			float2 SMin(float a, float b, float k)
			{
				float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
				return float2(lerp(b, a, h) - k * h * (1.0 - h), h);
			}
			
			float2 SMax(float a, float b, float k)
			{
				float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
				return float2(lerp(a, b, h) + k * h * (1.0 - h), h);
			}
			
			float SDSphere(float3 p, float3 pos, float s)
			{
				return length(p - pos) - s;
			}
			
			float SDCapsule(float3 p, float3 a, float3 b, float r)
			{
				float3 pa = p - a, ba = b - a;
				float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
				return length(pa - ba * h) - r;
			}
			
			float SDCappedCylinder(float3 p, float2 h)
			{
				float2 d = abs(float2(length(p.xz), p.y)) - h;
				return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
			}
			
			float3 OPCheapBend(float3 p, float strength)
			{
				float c = cos(strength * p.y);
				float s = sin(strength * p.y);
				float2x2 m = float2x2(c, -s, s, c);
				float3 q = float3(mul(m, p.xy), p.z);
				return q;
			}
			
			Mat Map(float3 p)
			{
				// returns a vec3 with x = distance, y = bump, z = mat transition w = mat id
				
				Mat o;
				
				o.m = 1.0;
				
				float t = _Time.y;
				
				//轻微的抖动偏移
				p.y += (sin(p.x * 10.0) * sin(p.y * 12.0)) * 0.01;
				float outside = SDCappedCylinder(p + float3(0., 2., 0.), float2(.75, 2.)) - .1;
				float inside = SDCappedCylinder(p - float3(0., 2., 0.), float2(.45, 2.)) - .3;
				
				//蜡烛的形状  两个胶囊合成
				float2 candle = SMax(outside, -inside, 0.1);
				
				//蜡烛芯
				float3 q = p + float3(0.0, 0.15, 0.0);
				q = OPCheapBend(q + float3(0.0, 0.2, 0.0) * 0.0, 1.0);
				float angle = atan2(q.x, q.z);//Maybe:BUG
				q.xz *= 1. - abs(sin(angle * twopi + q.y * 40.)) * .02 * smoothstep(.1, .2, q.y);
				q.xz *= 1. - smoothstep(.2, .0, q.y) * .2;
				float wick = SDCappedCylinder(q + float3(0., 0.1, 0.), float2(.01, .7)) - .05;
				
				float2 d = SMin(candle.x, wick, .2);
				
				
				o.uv = float2(angle, q.y);
				o.t = d.y;
				o.d = angle;//d.x * 0.8;
				o.w = wick;
				
				return o;
			}
			
			Mat FMap(float3 p, float n)
			{
				// returns a vec3 with x = distance, y = bump, z = mat transition w = mat id
				float t = _Time.y * 2.0;
				
				Mat o;
				
				o.m = 1.0;
				
				p.z *= 1.5; //约束宽度
				
				//火忽高忽低
				float spikes = pow(abs(sin(p.x * 50. + t * 2.)), 5.);
				spikes *= pow(abs(sin(p.x * - 30. + t * 1.)), 5.);
				p.y += spikes * .1 * smoothstep(1.5, 3., p.y);
				
				//弯曲 形成o形 烛火的点
				float3 q = OPCheapBend(p + float3(0, 0.2, 0), 1.0);
				//检测烛火距离
				float wick = SDCappedCylinder(q + float3(0., 0.1, 0.), float2(.01, .7)) - .01;
				float d = wick;
				float flame = wick;
				
				float t2 = t * 0.2;
				float top = 2.5 - n * n;
				for (float i = 0.0; i < 1.0; i += 1.0 / 20.0)
				{
					float y = lerp(0.3, top, i);
					float x = pow(abs(sin(y - t * 2.)), 2.) * .1 * n * p.y * n * n * n;
					
					//越往上面火越小
					float size = lerp(.1, .05, i * i);
					float smth = lerp(.4, .1, i);
					flame = SMin(flame, SDSphere(p, float3(x - .12, y, .0), size), smth).x;
				}
				
				d = min(d, flame);
				
				//烛火 下面的不显示
				d = max(d, -SDSphere(p, float3(-0.2, -0.5, 0.0), 0.5));
				o.d = d / 1.5;
				
				return o;
			}
			
			
			Mat CastRay(Ray r, float n)
			{
				float dmin = 1.0;
				float dmax = 100.0;
				
				float precis = RAY_PRECISION;
				
				Mat o;
				
				o.d = dmin;
				o.m = -1.0;
				o.w = 1000.0;
				o.s = 1000.0;
				
				Mat res;
				//蜡烛和灯芯的形状
				for (int i = 0; i < MAX_STEPS; i ++)
				{
					res = Map(r.o + r.d * o.d);
					if (res.d < precis || o.d > dmax)
					{
						break;
					}
					
					float d = o.d;
					float w = o.w;
					o = res;
					if(w < o.w)
					{
						o.w = w;
					}
					
					o.d += d;
				}
				
				if(o.d > dmax)
				{
					o.m = -1.0;
				}
				return o;
				o.s = 1000.0;
				o.fd = 0.0;
				for (int i = 0; i < MAX_STEPS; i++)
				{
					res = FMap(r.o + r.d * o.fd, n);
					if(res.d < precis || o.fd > dmax)
					{
						break;
					}
					if(res.d < o.s)
					{
						o.s = res.d;
						o.sd = o.fd;
					}
					
					o.fd += res.d;
				}
				
				if(res.d < precis)
				{
					o.f = 1.;
				}
				
				
				return o;
			}
			
			//End Material
			
			//Candle Render
			//-----------
			float4 CandleRender(float2 uv, Ray camRay, float n)
			{
				float3 col = float3(0, 0, 0);
				Mat o = CastRay(camRay, n);
				
				return o.d/100;
			}
			
			//End Render
			
			float3 CandleFrag(float2 uv, float m, float t)
			{
				uv *= 2;//[-1,1]
				
				InitCamera(uv, m, t);
				
				float t2 = 2.0 * t;
				float n = lerp(N(floor(t2)), N(floor(t2 + 1.)), frac(t2));
				
				
				float col = CandleRender(uv, cam.ray, n);

				return col;
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
				float2 uv = i.uv - 0.5;//[-0.5,0.5]
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				float2 m = _MousePos;//[0, 1]
				float t = _Time.y;
				
				
				
				float4 col = 0;
				
				col.rgb = CandleFrag(uv, m, t);

				return pow(col,2.2);
			}
			ENDCG
			
		}
	}
}
