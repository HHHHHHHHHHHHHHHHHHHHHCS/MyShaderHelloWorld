Shader "HCS/S_LensFlare_GhostFeature"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_NumGhost ("Number of Ghosts", int) = 2
		_Displace ("Displacement", float) = 0.1
		_Falloff ("Falloff", float) = 10
	}
	SubShader
	{
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
				float2 uv: TESSFACTOR0;
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			int _NumGhost;
			float _Displace;
			float _Falloff;
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = tex2D(_MainTex, i.uv);
				float2 uv = i.uv - float2(0.5, 0.5);
				
				for (int k = 3; k < _NumGhost + 3; k ++)
				{
					if (k & 1)
					{
						col += tex2D(_MainTex, -_Displace * uv / (k >> 1) + float2(0.5, 0.5));
					}
					else
					{
						col += tex2D(_MainTex, uv / (k >> 1) + float2(0.5, 0.5));
					}
				}
				
				col *= pow(1 - length(uv) / 0.707, _Falloff);
				return col;
			}
			ENDCG
			
		}
	}
}