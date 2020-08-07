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
				pos = mul(rotX, pos);//移动摄像机矩阵
				
				CameraSetup(uv, pos, lookAt, 3.0);
			}
			
			//End Camera
			
			float3 CandleFrag(float2 uv, float m, float t)
			{
				uv *= 2;//[-1,1]
				
				InitCamera(uv, m, t);
				
				float t2 = 2.0 * t;
				float n = lerp(N(floor(t2)), N(floor(t2 + 1.)), frac(t2));
				
				return n;
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
				
				return col;
			}
			ENDCG
			
		}
	}
}
