Shader "ShaderToy/S_FoamyWater"
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
			
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float time = _Time.y * 0.1 + 23.0;
				float2 uv = float2(i.uv.x * _ScreenParams.x / _ScreenParams.y, i.uv.y);
				
				float dist_center = pow(2.0 * length(uv - 0.5), 2.0);

				float 
				
				return 0;
			}
			ENDCG
			
		}
	}
}
