Shader "CommonEffect/S_097_TextureSwitch"
{
	Properties
	{
		_PlayerPos ("Player Position", vector) = (0.0, 0.0, 0.0, 0.0)
		_Dist ("Distance", float) = 5.0
		_MainTex ("Texture", 2D) = "white" { }
		_SecondayTex ("Secondary Texture", 2D) = "white" { }
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
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityWorldToClipPos(o.worldPos);
				o.uv = v.texcoord;
				return o;
			}
			
			float4 _PlayerPos;
			sampler2D _MainTex;
			sampler2D _SecondayTex;
			float _Dist;
			
			half4 frag(v2f i): SV_TARGET
			{
				if (distance(_PlayerPos.xyz, i.worldPos.xyz) > _Dist)
				{
					return tex2D(_MainTex, i.uv);
				}
				else
				{
					return tex2D(_SecondayTex, i.uv);
				}
			}
			
			ENDCG
			
		}
	}
}
