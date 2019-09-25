Shader "HCS/S_ClipBarrel"
{
	Properties
	{
		_ClipVal ("Clip Val", Vector) = (1, 1, 1, 0)
		_MainTex ("Main Texture", 2D) = "white" { }
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	#include "AutoLight.cginc"
	#include "Lighting.cginc"
	
	struct a2v
	{
		float4 vertex: POSITION;
		float2 uv: TEXCOORD0;
	};
	
	struct v2f
	{
		float4 vertex: SV_POSITION;
		float2 uv: TEXCOORD0;
		float3 modelPos: TEXCOORD1;
	};
	
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _ClipVal;
	
	v2f vert(a2v v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.modelPos = v.vertex.xyz ;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}
	
	half4 frag(v2f i): SV_TARGET
	{
		if (i.modelPos.y > _ClipVal.y || i.modelPos.x > _ClipVal.x || i.modelPos.z > _ClipVal.z)
		{
			discard;
		}
		return tex2D(_MainTex, i.uv);
	}
	
	ENDCG
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		
		
		Pass
		{
			Tags { "RenderMode" = "ForwardBase" }
			
			Cull Back
			
			Stencil
			{
				Ref 2
				Comp Always
				Pass Replace
			}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			ENDCG
			
		}
		
		
		Pass
		{
			Tags { "RenderMode" = "ForwardBase" }
			
			Cull Front
			
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
			}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			ENDCG
			
		}
		
		
		
		Pass
		{
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			
			#pragma vertex shadowVert
			#pragma fragment shadowFrag
			
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			
			struct shadowV2f
			{
				V2F_SHADOW_CASTER;
				float3 modelPos: TEXCOORD0;
			};
			
			shadowV2f shadowVert(appdata_base v)
			{
				shadowV2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.modelPos = v.vertex.xyz;
				return o;
			}
			
			float4 shadowFrag(shadowV2f i): SV_TARGET
			{
				if (i.modelPos.y > _ClipVal.y || i.modelPos.x > _ClipVal.x || i.modelPos.z > _ClipVal.z)
				{
					discard;
				}
				SHADOW_CASTER_FRAGMENT(i)
			}
			
			ENDCG
			
		}
	}
}

