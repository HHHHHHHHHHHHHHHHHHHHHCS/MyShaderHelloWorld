Shader "ObjectEffect/S_HexGridRings"
{
	Properties
	{
		_Spectra ("Spectra", Vector) = (0, 0, 0, 0)
		_Center ("Center", Vector) = (0.0, 0.0, 0.0)
		_RingSrtide ("Stride", Float) = 0.2
		_RingThicknessMin ("ThicknessMin", Float) = 0.1
		_RingThicknessMax ("ThicknessMax", Float) = 0.5
		[HDR] _RingColor ("RingEmission", Color) = (10, 0, 0, 1)
		_RingSpeedMin ("RingSpeedMin", Float) = 0.2
		_RingSpeedMax ("RingSpeedMin", Float) = 0.5
		[HDR] _GridColor ("GridColor", Color) = (1, 1, 1, 1)
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
			};
			
			struct v2f
			{
				float4 hclipPos: SV_POSITION;
				float4 wPos: TEXCOORD0;
			};
			
			float4 _Spectra;
			float3 _Center;
			float _RingSrtide;
			float _RingThicknessMin;
			float _RingThicknessMax;
			half4 _RingColor;
			float _RingSpeedMin;
			float _RingSpeedMax;
			half4 _GridColor;
			
			float MyRand(float  p)
			{
				return frac(sin(p) * 43758.5453);
			}
			
			float  MyMod(float  a, float  b)
			{
				return a - b * floor(a / b);
			}
			float2 MyMod(float2 a, float2 b)
			{
				return a - b * floor(a / b);
			}
			float3 MyMod(float3 a, float3 b)
			{
				return a - b * floor(a / b);
			}
			float4 MyMod(float4 a, float4 b)
			{
				return a - b * floor(a / b);
			}
			
			float Rings(float3 pos)
			{
				float2 wpos = pos.xz;
				
				float stride = _RingSrtide;
				float strine_half = stride * 0.5;
				float thickness = 1.0 - (_RingThicknessMin + length(_Spectra) * (_RingThicknessMax - _RingThicknessMin));
				float distance = abs(length(wpos) - _Time.y * 0.1);
				float fra = MyMod(distance, stride);
				float cycle = floor((distance) / stride);
				
				float c = strine_half - abs(fra - strine_half) - strine_half * thickness;
				c = max(c * (1.0 / (strine_half * thickness)), 0.0);
				
				float rs = MyRand(cycle * cycle);
				float r = MyRand(cycle) + _Time.y * (_RingSpeedMin + (_RingSpeedMax - _RingSpeedMin) * rs);
				
				float angle = atan2(wpos.y, wpos.x) / UNITY_PI * 0.5 + 0.5; // 0.0-1.0
				float a = 1.0 - MyMod(angle + r, 1.0);
				a = max(a - 0.7, 0.0) * c;
				return a;
			}
			
			float Hex(float2 p, float2 h)
			{
				float2 q = abs(p);
				return max(q.x - h.y, max(q.x + q.y * 0.57735, q.y * 1.1547) - h.x);
			}
			
			float HexGrid(float3 p)
			{
				float scale = 1.2;
				float2 grid = float2(0.692, 0.4) * scale;
				float radius = 0.22 * scale;
				
				float2 p1 = MyMod(p.xz, grid) - grid * 0.5;
				float c1 = Hex(p1, radius);
				
				float2 p2 = MyMod(p.xz + grid * 0.5, grid) - grid * 0.5;
				float c2 = Hex(p2, radius);
				return min(c1, c2);
			}
			
			float Circle(float3 pos)
			{
				float o_radius = 5.0;
				float i_radius = 4.0;
				float d = length(pos.xz);
				float c = max(MyMod(d - _Time.y * 1.5, o_radius) - i_radius, 0.0);
				return c;
			}
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.hclipPos = mul(UNITY_MATRIX_VP, o.wPos);
				return o;
			}
			
			half4 frag(v2f IN): SV_Target
			{
				float3 center = IN.wPos - _Center;
				float trails = Rings(center);
				float grid_d = HexGrid(center);
				float grid = grid_d > 0.0 ? 1.0: 0.0;
				float circle = Circle(center);
				
				half4 col = 0;
				
				col += trails * (0.5 + _Spectra * _RingColor);
				col += _GridColor * (grid * circle) ;
				
				return col;
			}
			ENDCG
			
		}
	}
}
