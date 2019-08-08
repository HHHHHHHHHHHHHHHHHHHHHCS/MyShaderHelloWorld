﻿Shader "CommonEffect/S_095_FlagWithLighting"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Ambient ("Ambient", Range(0.0, 1.0)) = 0.2
		[Header(Waves)]
		_WaveSpeed ("Speed", float) = 0.0
		_WaveStrength ("Strength", Range(0.0, 1.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		Cull Off
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 vertex: TEXCOORD1;
				float2 uv: TEXCOORD0;
			};
			
			half4 _LightColor0;
			float _Ambient;
			
			half3 diffuseLambert(float3 normal)
			{
				float diffuse = max(_Ambient, dot(_WorldSpaceLightPos0.xyz, normalize(normal)));
				return _LightColor0.rgb * diffuse;
			}
			
			float _WaveStrength;
			float _WaveSpeed;
			
			float4 movement(float4 pos, float2 uv)
			{
				float sinOff = (pos.x + pos.y + pos.z) * _WaveStrength;
				float t = _Time.y * _WaveSpeed;
				float fx = uv.x;
				float fy = uv.x * uv.y;
				pos.x += sin(t * 1.45 + sinOff) * fx * 0.5;
				pos.y = sin(t * 3.12 + sinOff) * fx * 0.5 - fy * 0.9;
				pos.z -= sin(t * 2.2 + sinOff) * fx * 0.2;
				return pos;
			}
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = v.vertex;
				o.pos = UnityObjectToClipPos(movement(v.vertex, v.texcoord));
				o.uv = v.texcoord;
				return o;
			}
			
			sampler2D _MainTex;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				
				float3 pos0 = movement(float4(i.vertex.x, i.vertex.y, i.vertex.z, i.vertex.w), i.uv).xyz;
				float3 pos1 = movement(float4(i.vertex.x + 0.01, i.vertex.y, i.vertex.z, i.vertex.w), i.uv).xyz;
				float3 pos2 = movement(float4(i.vertex.x, i.vertex.y, i.vertex.z + 0.01, i.vertex.w), i.uv).xyz;
				
				float3 normal = cross(normalize(pos2 - pos0), normalize(pos1 - pos0));
				
				float3 worldNormal = UnityObjectToWorldNormal(normal);
				
				col.rgb *= diffuseLambert(worldNormal);
				return col;
			}
			
			
			ENDCG
			
		}
	}
}