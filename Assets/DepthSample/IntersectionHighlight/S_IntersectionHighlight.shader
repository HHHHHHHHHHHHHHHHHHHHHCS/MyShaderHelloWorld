Shader "DepthSample/S_IntersectionHighlight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_IntersectionColor ("Intersection Color", Color) = (1, 0, 0, 1)
		_IntersectionWidth ("Intersection Width", Range(0, 1)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
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
				float4 vertex: SV_POSITION;
				float4 screenPos: TEXCOORD1;
				float eyeZ: TEXCOORD2;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			half4 _IntersectionColor;
			float _IntersectionWidth;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeZ);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				//自己没有渲染在深度图上
				float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				
				float halfWidth = _IntersectionWidth / 2;
				float diff = saturate(abs(i.eyeZ - screenZ) / halfWidth);
				
				half4 finalColor = lerp(_IntersectionColor, col, diff);
				return finalColor;
			}
			
			ENDCG
			
		}
	}
}
