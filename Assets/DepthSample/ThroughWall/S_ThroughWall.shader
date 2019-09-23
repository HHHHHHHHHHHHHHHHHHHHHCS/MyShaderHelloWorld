Shader "HCS/S_ThroughWall"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			ZTest Greater
			Blend One One
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
				
				float3 normal: NORMAL;
				float3 viewDir: TEXCOORD1;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _EdgeColor;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				return o;
			}
			
			
			half4 frag(v2f i): SV_TARGET
			{
				float NoL = 1 - dot(i.normal, i.viewDir) * 1.5;
				return _EdgeColor * NoL;
			}
			
			ENDCG
			
		}
		
		Pass
		{
			ZTest Less
			
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
				UNITY_FOG_COORDS(1)
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.vertex)
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			
			ENDCG
			
		}
	}
}
