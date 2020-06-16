Shader "GeometryObjSamples/S_CubeFade"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		[NoScaleOffset]_CubeTex ("Cube Texture", 2D) = "white" { }
		_CubeMinScale ("Cube Min Scale", Range(0, 10)) = 1
		_CubeMaxScale ("Cube Max Scale", Range(0, 10)) = 1
		_Progress ("Progress", Range(0, 1)) = 0
		_CubeProgress ("Cube Progress", Range(0, 1)) = 0
		_FadeColor ("Fade Color", Color) = (0.5, 0.5, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			Cull Off
			
			CGPROGRAM
			
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#include "UnityCG.cginc"
			#include "NoiseLib.cginc"
			
			
			struct v2g
			{
				float4 pos: POSITION;
				float3 normal: NORMAL;
				float2 uv: TEXCOORD0;
			};
			
			struct g2f
			{
				float2 uv: TEXCOORD0;//for new cube
				float4 pos: SV_POSITION;
				float3 normal: NORMAL;
				float2 baseUV: TEXCOORD1;//original object uv
			};
			
			float _CubeMinScale, _CubeMaxScale, _CubeProgress;
			sampler2D _MainTex, _CubeTex;
			float4 _MainTex_ST;
			
			g2f CreateG2F()
			{
				g2f o;
				o.pos = 0;
				o.uv = 0;
				o.normal = 0;
				o.baseUV = 0;
				return o;
			}
			
			v2g vert(appdata_base v)
			{
				v2g o = (v2g) 0;
				o.pos = v.vertex;
				o.normal = float3(0, 0, 0);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			void BuildCube(float2 uv, float3 center, float3 normal, float noise, inout g2f v[36], inout TriangleStream < g2f > triStream)
			{
				// top
				v[0].pos = float4(0, 1, 0, 0);
				v[0].uv = float2(0, 0);
				v[0].baseUV = uv;
				v[0].normal = float3(0, 1, 0);
				
				v[1].pos = float4(1, 1, 0, 0);
				v[1].uv = float2(1, 0);
				v[1].baseUV = uv;
				v[1].normal = float3(0, 1, 0);
				
				v[2].pos = float4(0, 1, 1, 0);
				v[2].uv = float2(0, 1);
				v[2].baseUV = uv;
				v[2].normal = float3(0, 1, 0);
				
				v[3].pos = float4(1, 1, 1, 0);
				v[3].uv = float2(1, 1);
				v[3].baseUV = uv;
				v[3].normal = float3(0, 1, 0);
				
				// btm
				v[4].pos = float4(0, 0, 0, 0);
				v[4].uv = float2(0, 0);
				v[4].baseUV = uv;
				v[4].normal = float3(0, -1, 0);
				
				v[5].pos = float4(1, 0, 0, 0);
				v[5].uv = float2(1, 0);
				v[5].baseUV = uv;
				v[5].normal = float3(0, -1, 0);
				
				v[6].pos = float4(0, 0, 1, 0);
				v[6].uv = float2(0, 1);
				v[6].baseUV = uv;
				v[6].normal = float3(0, -1, 0);
				
				v[7].pos = float4(1, 0, 1, 0);
				v[7].uv = float2(1, 1);
				v[7].baseUV = uv;
				v[7].normal = float3(0, -1, 0);
				
				// forward
				v[8].pos = float4(0, 0, 1, 0);
				v[8].uv = float2(0, 0);
				v[8].baseUV = uv;
				v[8].normal = float3(0, 0, 1);
				
				v[9].pos = float4(1, 0, 1, 0);
				v[9].uv = float2(1, 0);
				v[9].baseUV = uv;
				v[9].normal = float3(0, 0, 1);
				
				v[10].pos = float4(0, 1, 1, 0);
				v[10].uv = float2(0, 1);
				v[10].baseUV = uv;
				v[10].normal = float3(0, 0, 1);
				
				v[11].pos = float4(1, 1, 1, 0);
				v[11].uv = float2(1, 1);
				v[11].baseUV = uv;
				v[11].normal = float3(0, 0, 1);
				
				// backward
				v[12].pos = float4(0, 0, 0, 0);
				v[12].uv = float2(0, 0);
				v[12].baseUV = uv;
				v[12].normal = float3(0, 0, -1);
				
				v[13].pos = float4(1, 0, 0, 0);
				v[13].uv = float2(1, 0);
				v[13].baseUV = uv;
				v[13].normal = float3(0, 0, -1);
				
				v[14].pos = float4(0, 1, 0, 0);
				v[14].uv = float2(0, 1);
				v[14].baseUV = uv;
				v[14].normal = float3(0, 0, -1);
				
				v[15].pos = float4(1, 1, 0, 0);
				v[15].uv = float2(1, 1);
				v[15].baseUV = uv;
				v[15].normal = float3(0, 0, -1);
				
				//left
				v[16].pos = float4(0, 0, 0, 0);
				v[16].uv = float2(0, 0);
				v[16].baseUV = uv;
				v[16].normal = float3(-1, 0, 0);
				
				v[17].pos = float4(0, 1, 0, 0);
				v[17].uv = float2(1, 0);
				v[17].baseUV = uv;
				v[17].normal = float3(-1, 0, 0);
				
				v[18].pos = float4(0, 0, 1, 0);
				v[18].uv = float2(0, 1);
				v[18].baseUV = uv;
				v[18].normal = float3(-1, 0, 0);
				
				v[19].pos = float4(0, 1, 1, 0);
				v[19].uv = float2(1, 1);
				v[19].baseUV = uv;
				v[19].normal = float3(-1, 0, 0);
				
				// right
				v[20].pos = float4(1, 0, 0, 0);
				v[20].uv = float2(0, 0);
				v[20].baseUV = uv;
				v[20].normal = float3(1, 0, 0);
				
				v[21].pos = float4(1, 1, 0, 0);
				v[21].uv = float2(1, 0);
				v[21].baseUV = uv;
				v[21].normal = float3(1, 0, 0);
				
				v[22].pos = float4(1, 0, 1, 0);
				v[22].uv = float2(0, 1);
				v[22].baseUV = uv;
				v[22].normal = float3(1, 0, 0);
				
				v[23].pos = float4(1, 1, 1, 0);
				v[23].uv = float2(1, 1);
				v[23].baseUV = uv;
				v[23].normal = float3(1, 1, 1);
				
				float4 offset = float4(random4(float4(center, _Time.x * 0.0001)).xyz, 0);
				float4 scale = lerp(_CubeMinScale, _CubeMaxScale, random3(float3(uv, 0)).x);
				scale *= saturate(noise / - 0.05);
				for (int i = 0; i < 24; ++ i)
				{
					v[i].pos = UnityObjectToClipPos(center
					+ (v[i].pos - float4(0.5, 0.5, 0.5, 0)
					//random position
					+ offset * 0.2 + normal * 2)
					//random size
					* scale);
				}
				
				triStream.Append(v[0]); triStream.Append(v[2]); triStream.Append(v[1]); triStream.RestartStrip();
				triStream.Append(v[1]); triStream.Append(v[2]); triStream.Append(v[3]); triStream.RestartStrip();
				triStream.Append(v[4]); triStream.Append(v[5]); triStream.Append(v[6]); triStream.RestartStrip();
				triStream.Append(v[5]); triStream.Append(v[7]); triStream.Append(v[6]); triStream.RestartStrip();
				triStream.Append(v[8]); triStream.Append(v[9]); triStream.Append(v[10]); triStream.RestartStrip();
				triStream.Append(v[9]); triStream.Append(v[11]); triStream.Append(v[10]); triStream.RestartStrip();
				triStream.Append(v[12]); triStream.Append(v[14]); triStream.Append(v[13]); triStream.RestartStrip();
				triStream.Append(v[13]); triStream.Append(v[14]); triStream.Append(v[15]); triStream.RestartStrip();
				triStream.Append(v[16]); triStream.Append(v[18]); triStream.Append(v[17]); triStream.RestartStrip();
				triStream.Append(v[17]); triStream.Append(v[18]); triStream.Append(v[19]); triStream.RestartStrip();
				triStream.Append(v[20]); triStream.Append(v[21]); triStream.Append(v[22]); triStream.RestartStrip();
				triStream.Append(v[21]); triStream.Append(v[23]); triStream.Append(v[22]); triStream.RestartStrip();
			}
			
			[maxvertexcount(72)]
			void geom(line v2g p[2], inout TriangleStream < g2f > triStream)
			{
				float noise = pnoise(float3(p[0].uv, 0), 10) * 0.5 + 0.5 - _CubeProgress;
				if (noise < 0)
				{
					int initIdx = 0;
					g2f vFirstPoint[36];
					for (initIdx = 0; initIdx < 36; ++ initIdx)
					{
						vFirstPoint[initIdx] = CreateG2F();
					}
					BuildCube(p[0].uv, p[0].pos, p[0].normal, noise, vFirstPoint, triStream);
					g2f vSecondPoint[36];
					for (initIdx = 0; initIdx < 36; ++ initIdx)
					{
						vSecondPoint[initIdx] = CreateG2F();
					}
					BuildCube(p[1].uv, p[1].pos, p[1].normal, noise, vFirstPoint, triStream);
				}
			}
			
			float4 frag(g2f i): SV_TARGET
			{
				return tex2D(_CubeTex, i.uv);
			}
			
			ENDCG
			
		}
		
		Pass
		{
			Cull Off
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "NoiseLib.cginc"
			
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
			
			float _Progress;
			sampler2D _MainTex, _CubeTex;
			float4 _MainTex_ST, _FadeColor;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float noise = pnoise(float3(i.uv, 0), 10) * 0.5 + 0.5 - _Progress;
				clip(noise);
				float4 col = tex2D(_MainTex, i.uv);
				if (noise <= 0.2)
					return lerp(_FadeColor, col, noise / 0.2);
				return col;
			}
			ENDCG
			
		}
	}
}
