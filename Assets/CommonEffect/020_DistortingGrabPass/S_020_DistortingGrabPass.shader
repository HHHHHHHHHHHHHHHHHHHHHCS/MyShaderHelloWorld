Shader "CommonEffect/S_020_DistortingGrabPass"
{
	Properties
	{
		_Intensity("Intensity",Range(0,50)) = 0
	}
	SubShader
	{
		GrabPass {"_GrabTexture"}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				half4 pos:SV_POSITION;
				half4 grabPos:TEXCOORD;
			};

			float _Intensity;
			sampler2D _GrabTexture;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos =UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos);
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				i.grabPos.x += sin((_Time.y + i.grabPos.y) * _Intensity ) / 20;
				half4 color = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.grabPos));
				return color;
			}

			ENDCG
		}
	}
}
