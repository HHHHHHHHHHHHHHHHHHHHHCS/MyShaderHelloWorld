Shader "Other/S_ChessTerrain"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" { }
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0.0
		_Tess ("Tessellation", Range(1, 32)) = 4
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf Standard fullforwardshadows vertex:vert //tessellate:tessDistance
		
		#include "Tessellation.cginc"
		
		struct Input
		{
			float2 uv_MainTex;
			float4 color;
		};
		
		
		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		half4 _Color;
		float _Tess;
		float TextureWidthInWorldSpace;
		float3 PlayerStand;
		#ifdef SHADER_API_D3D11
			StructuredBuffer<float> Result;
		#endif
		
		
		float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2)
		{
			float minDist = 50.0;
			float maxDist = 1000.0;
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
		}
		
		
		#ifdef SHADER_API_D3D11
			float S(int3 coord)
			{
				return Result[coord.x + coord.z * 256 + coord.y * 256 * 256];
			}
			
			float Sample(int3 icoord, float3 coord)
			{
				float _000 = S(icoord);
				float _001 = S(icoord + int3(0, 0, 1));
				float _010 = S(icoord + int3(0, 1, 0));
				float _100 = S(icoord + int3(1, 0, 0));
				float _110 = S(icoord + int3(1, 1, 0));
				float _011 = S(icoord + int3(0, 1, 1));
				float _101 = S(icoord + int3(1, 0, 1));
				float _111 = S(icoord + int3(1, 1, 1));
				float _x00 = lerp(_000, _100, coord.x);
				float _x10 = lerp(_010, _110, coord.x);
				float _x01 = lerp(_001, _101, coord.x);
				float _x11 = lerp(_011, _111, coord.x);
				float _xy0 = lerp(_x00, _x10, coord.y);
				float _xy1 = lerp(_x01, _x11, coord.y);
				return lerp(_xy0, _xy1, coord.z);
			}
		#endif
		
		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			#ifdef SHADER_API_D3D11
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				worldPos /= worldPos.w;
				float3 vInSDF = worldPos - PlayerStand;
				if (abs(vInSDF.x) > 0.5 * TextureWidthInWorldSpace ||
				abs(vInSDF.y) > 0.5 * TextureWidthInWorldSpace ||
				abs(vInSDF.z) > 0.5 * TextureWidthInWorldSpace)
					return;
				float PixelToSpaceDistance = 256. / 16. / TextureWidthInWorldSpace ;
				vInSDF.xz += 0.5 * TextureWidthInWorldSpace;
				vInSDF.y += 0.25 * 0.5 * TextureWidthInWorldSpace;
				float3 _zero = ((vInSDF) / PixelToSpaceDistance);
				int3 izero = (int3)floor(_zero);
				float3 fzero = _zero - izero;
				float f = Sample(izero, fzero);
				f /= 10.;
				f *= f;
				f *= 10;
				f = sqrt(f);
				v.vertex.y += f;
				// 算了，再采法线
				float3 dx = float3(izero.x,
				Sample(izero + int3(0, 0, 1), fzero) - Sample(izero - int3(0, 0, 1), fzero), 0);
				float3 dz = float3(0,
				Sample(izero + int3(0, 1, 0), fzero) - Sample(izero - int3(0, 1, 0), fzero), izero.z);
				float3 n = normalize(cross(dz, dx));
				n = mul((float3x3)unity_WorldToObject, n);
				v.normal = n;
			#endif
		}
		
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			#if SHADER_API_D3D11
				//o.Albedo = IN.color;
			#endif
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
		
	}
	FallBack "Diffuse"
}
