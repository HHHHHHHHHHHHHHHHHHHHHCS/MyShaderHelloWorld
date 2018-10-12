Shader "HCS/S_DeferredLights" 
{
	Properties 
	{

	}
	SubShader 
	{
		pass
		{
			Cull Off
			ZTest Always
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag



			#pragma exclude_renderers nomrt

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex :POSITION;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(v2f i):SV_TARGET
			{
				return 0;
			}

			ENDCG
		}

		pass
		{
			Cull Off
			ZTest Always
			ZWrite Off

			Stencil
			{
				Ref[_StencilNonBackground]
				ReadMask[_StenilNonBackground]
				CompBack Equal
				CompFront Equal
			}

			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#pragma exclude_renderers nomrt

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex :POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _LightBuffer;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv=v.uv;
				return o;
			}

			float4 frag(v2f i):SV_TARGET
			{
				return -log2(tex2D(_LightBuffer, i.uv));
			}

			ENDCG
		}
	}
	FallBack off
}
