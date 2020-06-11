Shader "CommandBufferSamples/S_UberShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
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
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _BlurCopyTex, _OutlineCopyTex;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				float4 blur = tex2D(_BlurCopyTex, i.uv);
				col = lerp(col, blur, blur.a);
				
				float4 outline_u = tex2D(_OutlineCopyTex, i.uv + float2(0, _MainTex_TexelSize.y));
				float4 outline_d = tex2D(_OutlineCopyTex, i.uv + float2(0, -_MainTex_TexelSize.y));
				float4 outline_l = tex2D(_OutlineCopyTex, i.uv + float2(_MainTex_TexelSize.x, 0));
				float4 outline_r = tex2D(_OutlineCopyTex, i.uv + float2(-_MainTex_TexelSize.x, 0));
				float4 outline = 0.5 * abs(outline_u - outline_d) + abs(outline_l - outline_r);
				
				return col + outline;
			}
			ENDCG
			
		}
	}
}
