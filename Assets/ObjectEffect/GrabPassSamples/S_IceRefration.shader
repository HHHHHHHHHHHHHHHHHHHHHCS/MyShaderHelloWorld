Shader "ObjectEffect/S_IceRefration"
{
	Properties
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("BaseTex", 2D) = "white" { }
		_BumpMap ("NormalMap", 2D) = "bump" { }
		_BumpAmt ("Distortion", Range(0, 1)) = 0.12
	}
	
	//Category:是渲染命令的逻辑组，着色器可以多个子着色器，他们需要共同的效果
	Category
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
		ZWrite Off
		
		SubShader
		{
			GrabPass
			{
				"_GrabTex"
			}
			
			Pass
			{
				CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
				
				struct a2v
				{
					float4 vertex: POSITION;
					float2 texcoord: TEXCOORD0;
				};
				
				struct v2f
				{
					float4 vertex: SV_POSITION;
					float4 uvgrab: TEXCOORD0;
					float2 uvbump: TEXCOORD1;
					float2 uvmain: TEXCOORD2;
					UNITY_FOG_COORDS(3)
				};
				
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				sampler2D _GrabTex;
				float4 _Color;
				float _BumpAmt;
				
				v2f vert(a2v v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					/*
					#if UNITY_UV_STARTS_AT_TOP
						float scale = -1.0;
					#else
						float scale = 1.0;
					#endif
					o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
					o.uvgrab.zw = o.vertex.zw;
					*/
					//跟上面的同效果
					o.uvgrab = ComputeGrabScreenPos(o.vertex);
					o.uvbump = TRANSFORM_TEX(v.texcoord, _BumpMap);
					o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
					UNITY_TRANSFER_FOG(o, o.vertex);
					return o;
				}
				
				float4 frag(v2f i): SV_TARGET
				{
					float2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
					
					float2 offset = bump * _BumpAmt;
					i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
					
					float4 col = tex2Dproj(_GrabTex, UNITY_PROJ_COORD(i.uvgrab));
					float4 tint = tex2D(_MainTex, i.uvmain) * _Color * 2.0;
					col *= tint;
					UNITY_APPLY_FOG(i.foogCoord, col);
					return col;
				}
				
				ENDCG
				
			}
		}
	}
}
