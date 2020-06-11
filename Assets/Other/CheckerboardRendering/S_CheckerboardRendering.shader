Shader "CheckerboardRendering/S_CheckerboardRendering"
{
	Properties { }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			HLSLPROGRAM
			
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
			
			Texture2DMS < float4, 2 > _RT0;
			Texture2DMS < float4, 2 > _RT1;
			Texture2D _MotionTexture;
			
			uint _FrameCnt;
			
			const float Epsilon = 0.00001;
			
			#define Up 0
			#define Down 1
			#define Left 2
			#define Right 3
			
			float4 ReadFromQuadrant(int2 pixel, int quadrant)
			{
				//Texture2DMS 是多张图  Load(pixel, 1)  后面的index指定那张图
				[branch]
				if (0 == quadrant)
				{
					return _RT0.Load(pixel, 1);
				}
				else if(1 == quadrant)
				{
					return _RT1.Load(pixel + int2(1, 0), 1);
				}
				else if(2 == quadrant)
				{
					return _RT1.Load(pixel, 0);
				}
				else //if(3 == quadrant)
				{
					return _RT0.Load(pixel, 0);
				}
			}
			
			float4 ColorFromCardinalOffsets(uint2 qtr_res_pixel, int2 offsets[4], int quadrants[2])
			{
				float4 color[4];
				
				float2 w;
				
				color[Up] = ReadFromQuadrant(qtr_res_pixel + offsets[Up], quadrants[0]);
				color[Down] = ReadFromQuadrant(qtr_res_pixel + offsets[Down], quadrants[0]);
				color[Left] = ReadFromQuadrant(qtr_res_pixel + offsets[Left], quadrants[1]);
				color[Right] = ReadFromQuadrant(qtr_res_pixel + offsets[Right], quadrants[1]);
				
				return float4((color[Up].rgb + color[Down].rgb + color[Left].rgb + color[Right].rgb) * 0.25, 1.0);
			}
			
			void GetCardinalOffsets(int quadrant, out int2 offsets[4], out int quadrants[2])
			{
				if (quadrant == 0)
				{
					offsets[Up] = -int2(0, 1);
					offsets[Down] = 0;
					offsets[Left] = -int2(1, 0);
					offsets[Right] = 0;
					
					quadrants[0] = 2;
					quadrants[1] = 1;
				}
				else if(quadrant == 1)
				{
					offsets[Up] = -int2(0, 1);
					offsets[Down] = 0;
					offsets[Left] = 0;
					offsets[Right] = +int2(1, 0);
					
					quadrants[0] = 3;
					quadrants[1] = 0;
				}
				else if(quadrant == 2)
				{
					offsets[Up] = 0;
					offsets[Down] = +int2(0, 1);
					offsets[Left] = -int2(1, 0);
					offsets[Right] = 0;
					
					quadrants[0] = 0;
					quadrants[1] = 3;
				}
				else if(quadrant == 3)
				{
					offsets[Up] = 0;
					offsets[Down] = +int2(0, 1);
					offsets[Left] = 0;
					offsets[Right] = +int2(1, 0);
					
					quadrants[0] = 1;
					quadrants[1] = 2;
				}
			}
			
			float4 GetComposeColor(uint2 samplePos)
			{
				float2 vel = _MotionTexture.Load(uint3(samplePos * 0.5f, 0)).rg;
				
				uint quadrant = (samplePos.x & 0x1) + (samplePos.y & 0x1) * 2;
				uint2 qitPixel = floor(samplePos.xy * 0.5f);
				
				uint frameQuadrants[2];
				const uint _FrameLookup[2][2] = {
					
					{
						0, 3
					},
					{
						1, 2
					}
				};
				
				frameQuadrants[0] = _FrameLookup[_FrameCnt][0];
				frameQuadrants[1] = _FrameLookup[_FrameCnt][1];
				
				[branch]
				if(frameQuadrants[0] == quadrant || frameQuadrants[1] == quadrant)
				{
					//match current frame,sample frame N
					return ReadFromQuadrant(qitPixel, quadrant);
				}
				else
				{
					//mismatch current frame, sample frame N-1
					uint2 preSamplePos = samplePos.xy + float2(0.5f, 0.5f) - vel;
					uint quadrantPrev = (preSamplePos.x & 0x1) + (preSamplePos & 0x1) * 2;
					int2 prevCenterPixel = floor(preSamplePos.xy * 0.5f);
					
					//check missing pixel
					bool missingPixel = false;
					
					//Quadrants check
					[branch]
					if (frameQuadrants[0] == quadrantPrev || frameQuadrants[1] == quadrantPrev)
					{
						missingPixel = true;
					}
					else if(abs(vel.x) > Epsilon || abs(vel.y) > Epsilon)
					{
						missingPixel = true;
					}
					
					[branch]
					if(missingPixel)
					{
						int2 cardinal_offsets[4];
						int cardinal_quadrants[2];
						GetCardinalOffsets(qitPixel, cardinal_offsets, cardinal_quadrants);
						
						return ColorFromCardinalOffsets(qitPixel, cardinal_offsets, cardinal_quadrants);
					}
					
					return ReadFromQuadrant(prevCenterPixel, quadrantPrev);
				}
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
				uint2 samplePos = i.uv.xy * _ScreenParams.xy;
				//samplePos.y = _ScreenParams.y - samplePos.y;
				return GetComposeColor(samplePos);
			}
			ENDHLSL
			
		}
	}
}
