Shader "HCS/S_DepthOfFieldBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BlurLevel ("Blur Level", Range(0,100)) = 10
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		
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
				float2 uv[9]: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurLevel;
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				float3 offset = float3(-1, 1, 0);
				float2 step = _MainTex_TexelSize.xy * _BlurLevel;
				
				o.uv[0] = v.uv + step * offset.xx ;
				o.uv[1] = v.uv + step * offset.xz ;
				o.uv[2] = v.uv + step * offset.xy ;
				o.uv[3] = v.uv + step * offset.zx ;
				o.uv[4] = v.uv + step * offset.zz ;
				o.uv[5] = v.uv + step * offset.zy ;
				o.uv[6] = v.uv + step * offset.yx ;
				o.uv[7] = v.uv + step * offset.yz ;
				o.uv[8] = v.uv + step * offset.yy ;
				
				
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = 0;
				[unroll]
				for (int index = 0; index < 9; index ++)
				{
					col += tex2D(_MainTex, i.uv[index]);
				}
				col /= 9;
				return col;
			}
			
			ENDCG
			
		}
	}
}
