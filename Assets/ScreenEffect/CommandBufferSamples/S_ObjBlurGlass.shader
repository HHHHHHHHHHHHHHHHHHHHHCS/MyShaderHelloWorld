Shader "CommandBufferSamples/S_ObjBlurGlass"
{
	Properties { }
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
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
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float4 srcUV: TEXCOORD1;
			};
			
			sampler2D _BlurTempTex;
			
			v2f vert(appdata v)
			{
				
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				//ComputeGrabScreenPos 会考虑 RT 的翻转情况
				o.srcUV = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float3 col = tex2Dproj(_BlurTempTex, i.srcUV).rgb;
				return float4(col, 1.0);
			}
			ENDCG
			
		}
	}
}
