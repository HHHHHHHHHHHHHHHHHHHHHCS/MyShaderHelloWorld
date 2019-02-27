Shader "CommonEffect/S_014_GrabPass"
{
	Properties
	{
		_OffsetX("OffsetX",Range(-1,1)) = 0
		_OffsetY("OffsetY",Range(-1,1)) = 0
		_ZoomVal("Zoom value",Range(0,20)) = 0

	}
	SubShader
	{
		GrabPass{"_GrabTexture"}

		Pass
		{
			Tags{"Queue"="Transparent"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f
			{
				half4 pos:SV_POSITION;
				half4 grabPos:TEXCOORD0;
			};

			half _OffsetX;
			half _OffsetY;
			sampler2D _GrabTexture;
			half _ZoomVal;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos +half4(_OffsetX,_OffsetY,0,_ZoomVal));
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 color = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.grabPos));
				half val = (color.x+color.y+color.z)/3;
				return half4(val,val,val,color.a);
			}

			ENDCG
		}
	}
}
