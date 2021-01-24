Shader "ObjectEffect/S_CelestialMap"
{
	Properties
	{
		_RandomSize ("RandomSize", Range(0, 1)) = 0
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			float _RandomSize;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float Random2(float2 p)
			{
				return frac(sin(dot(p, float2(114.5, 141.9))) * 643.1);
			}
			
			float2 Random22(float2 p)
			{
				return frac(sin(float2(
					dot(p, float2(114.5, 141.9)),
					dot(p, float2(364.3, 648.8))
				)) * 643.1);
			}
			
			float Random4(float4 p)
			{
				return frac(sin(dot(p, float4(114.5, 141.9, 198.10, 175.5))) * 643.1);
			}
			
			float2x2 Rot(float a)
			{
				float c = cos(a);
				float s = sin(a);
				return float2x2(
					c, s,
					- s, c
				);
			}
			
			//把A~B重新映射到0~1的范围
			float Remap01(float a, float b, float t)
			{
				return saturate((t - a) / (b - a));
			}
			
			//将a~b范围的t重新映射到c~d范围
			float Remap(float a, float b, float c, float d, float t)
			{
				//??:saturate
				return((t - a) / (b - a)) * (d - c) + c;
			}
			
			//在rect里面
			float2 Within(float2 uv, float4 rect)
			{
				return(uv - rect.xy) / (rect.zw - rect.xy);
			}
			
			void Ring(inout float3 rgb, float2 center, float l, float2 cruv, float rad, float thickness, float3 col)
			{
				float s1 = smoothstep(0, 1, (length(cruv - center) - rad - thickness / _ScreenParams.x) * _ScreenParams.x);
				float s2 = smoothstep(1, 0, (length(cruv - center) - rad + thickness / _ScreenParams.x) * _ScreenParams.x);
				rgb = lerp(col, rgb, max(s1, s2));
			}
			
			void RingInterval(inout float3 rgb, float2 center, float l, float2 cruv, float rad, float thickness, float3 col, int count)
			{
				float s1 = smoothstep(0, 1, (length(cruv - center) - rad - thickness / _ScreenParams.x) * _ScreenParams.x);
				float s2 = smoothstep(1, 0, (length(cruv - center) - rad + thickness / _ScreenParams.x) * _ScreenParams.x);
				float c = atan(cruv.y / cruv.x);
				c = step(frac(c / UNITY_PI * count + 0.25), 0.5);
				rgb = lerp(col, rgb, max(c, max(s1, s2)));
			}
			
			void Circle(inout float3 rgb, float2 cruv, float2 center, float rad, float3 col)
			{
				float l = length(cruv - center);
				float s = smoothstep(0, 1, (l - rad / _ScreenParams.x) * _ScreenParams.x);
				rgb = lerp(col, rgb, s);
			}
			
			void DrawLineWithLimit(inout float3 rgb, float2 cruv, float2 cruv1, float2 cruv2, float3 col, float width, float limitR, float l)
			{
				float2 d1 = cruv - cruv1;
				float2 d2 = cruv2 - cruv1;
				float h = saturate(dot(d1, d2) / dot(d2, d2));
				h = length(d1 - d2 * h);
				//h = step(h,width/_ScreenParams.x+0.5);
				h = smoothstep(1.0, 0.0, (h - width / _ScreenParams.x) * _ScreenParams.x);
				h = min(h, step(l, limitR));
				rgb = lerp(rgb, col, h);
			}
			
			void DrawCelestialMap(float2 cruv, float l, inout float3 rgb, float3 col)
			{
				float2 XYLimit = float2(0.5, 0.5 * _ScreenParams.y / _ScreenParams.x);
				float rep = 15;
				XYLimit *= rep * 0.3;
				XYLimit = ceil(XYLimit);
				float2 sp = cruv * rep;
				float2 p_int0 = floor(sp);
				float minDist = rep * 10;
				// float2 fsp = frac(sp);
				// if (fsp.x < 0.03 || fsp.y < 0.03)
				// {
				// 	rgb = lerp(float3(1, 0, 0), rgb, 0);
				// }
				for (int m = -XYLimit.x; m < XYLimit.x; m ++)
				{
					for (int n = -XYLimit.y; n < XYLimit.y; n ++)
					{
						float2 newP_int0 = p_int0 + int2(m, n);
						float2 r = (Random22(newP_int0) * 2 - 1) * _RandomSize;
						float2 newP_int1 = (newP_int0 + r) / rep;
						float len = length(cruv - newP_int1);
						float s = smoothstep(0, 1, (len - (2 + 8 * Random2(newP_int1)) / _ScreenParams.x) * _ScreenParams.x);
						s = max(s, step(0.415, l));
						rgb = lerp(col, rgb, s);
						//找到下一个点,划线
						float2 nextP_int0 = newP_int0 + int2(1, 0);
						r = (Random22(nextP_int0) * 2 - 1) * _RandomSize;
						nextP_int0 = (nextP_int0 + r) / rep;
						if (Random2(nextP_int0 + newP_int1) > 0.6)
						{
							DrawLineWithLimit(rgb, cruv, nextP_int0, newP_int1, 1, 2, 0.415, l);
						}
						nextP_int0 = newP_int0 + int2(0, 1);
						r = (Random22(nextP_int0) * 2 - 1) * _RandomSize;
						nextP_int0 = (nextP_int0 + r) / rep;
						if (Random2(nextP_int0 + newP_int1) > 0.6)
						{
							DrawLineWithLimit(rgb, cruv, nextP_int0, newP_int1, 1, 2, 0.415, l);
						}
					}
				}
			}
			
			float4 frag(v2f i): SV_TARGET
			{
				float2 cuv = i.uv - 0.5;
				float2 cruv = cuv;
				cruv.x /= _ScreenParams.y / _ScreenParams.x;
				//铺底色
				float4 col = 0;
				col.rgb = lerp(float3(0, 0, 165. / 255.), float3(45. / 255., 85. / 255., 205. / 255.), i.uv.y);
				//中心发亮
				float l = length(cruv);
				col.rgb = lerp(float3(100. / 255., 149. / 255., 237. / 255.), col.rgb, saturate(l / 0.415));
				//画第1个circle
				float s1, s2;
				Ring(col.rgb, 0, l, cruv, 0.45, 5, 1);
				//画第2个circle
				Ring(col.rgb, 0, l, cruv, 0.42, 1, 1);
				Ring(col.rgb, 0, l, cruv, 0.415, 1, 1);
				//画第3个circle,虚线
				RingInterval(col.rgb, 0, l, cruv, 0.43, 1.0, 0.5, 48);
				// 画第4个circle
				Ring(col.rgb, 0, l, cruv, 0.35, 1, .7);
				// 画第5个circle
				Ring(col.rgb, 0, l, cruv, 0.25, 2, 1);
				// 画第6个circle
				Ring(col.rgb, 0, l, cruv, 0.075, 1, .7);
				// 画第7个circle
				Ring(col.rgb, 0, l, cruv, 0.1625, 1, .7);
				// 画一个偏心圆
				RingInterval(col.rgb, float2(0.1, 0.1), l, cruv, 0.25, 2, float3(.4, .4, 1), 48);
				
				//画直线,先是十字
				s1 = smoothstep(1, 0, abs(cruv.x - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(cruv.y - 0) - 0.415)) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, 0.7, s1 * s2);
				s1 = smoothstep(1, 0, abs(cruv.y - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(cruv.x - 0) - 0.415)) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, 0.7, s1 * s2);
				
				//画斜线,就是rotate 在限制范围
				//先把线旋转回来
				float2 rruv = mul(cruv, Rot(UNITY_PI / 3.0));
				s1 = smoothstep(0, 1, abs(saturate(abs(rruv.y - 0) - 0.075)) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(rruv.y - 0) - 0.415)) * _ScreenParams.x);
				s2 = min(s1, s2);
				s1 = smoothstep(1, 0, abs(rruv.x - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, 0.7, s1 * s2);
				s1 = smoothstep(0, 1, abs(saturate(abs(rruv.x - 0) - 0.075)) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(rruv.x - 0) - 0.415)) * _ScreenParams.x);
				s2 = min(s1, s2);
				s1 = smoothstep(1, 0, abs(rruv.y - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, .7, s1 * s2);
				rruv = mul(cruv, Rot(-UNITY_PI / 3.));
				s1 = smoothstep(0, 1, abs(saturate(abs(rruv.y - 0) - 0.075)) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(rruv.y - 0) - 0.415)) * _ScreenParams.x);
				s2 = min(s1, s2);
				s1 = smoothstep(1, 0, abs(rruv.x - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, .7, s1 * s2);
				s1 = smoothstep(0, 1, abs(saturate(abs(rruv.x - 0) - 0.075)) * _ScreenParams.x);
				s2 = smoothstep(1, 0, abs(saturate(abs(rruv.x - 0) - 0.415)) * _ScreenParams.x);
				s2 = min(s1, s2);
				s1 = smoothstep(1, 0, abs(rruv.y - 0 - 1.5 / _ScreenParams.x) * _ScreenParams.x);
				col.rgb = lerp(col.rgb, .7, s1 * s2);
				// 画星空，因为要旋转，扔进函数里保证上下文了
				DrawCelestialMap(mul(cruv, Rot(_Time.x)), l, col.rgb, 1);
				return col;
			}
			
			ENDCG
			
		}
	}
}
