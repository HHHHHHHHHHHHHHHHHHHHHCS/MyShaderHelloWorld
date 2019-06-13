Shader "Custom/S_KinoGlitch"
{
	Properties
	{
		_MainTex ("Main Texture", 2d) = "white" { }
	}
	SubShader
	{
		Pass
		{
			Tags { "Queue" = "Opaque" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				half4 vertex: POSITION;
				half4 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half4 uv: TEXCOORD0;
			};
			
			sampler2D _MainTex;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o ;
			}
			
			float nrand(float x, float y)
			{
				return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float jitter = nrand(i.uv.x, _Time.x) * 2 - 1;
				return tex2D(_MainTex, i.uv);
			}
			
			
			
			
			ENDCG
			
		}
	}
}
