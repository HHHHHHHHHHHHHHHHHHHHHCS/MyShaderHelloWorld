Shader "CommonEffect/S_002_RotatingVanishingLines"
{
	Properties
	{
		_OrigineX ("PosX Origine",Range(0,1)) = 0.5
		_OrigineY ("PosY Origine",Range(0,1)) = 0.5
		_Speed ("Speed",Range(-100,100)) = 60.0
		_CircleNbr("Circle Quantity",Range(10,1000)) = 60
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma target 3.0


			float _OrigineX;
			float _OrigineY;
			float _Speed;
			float _CircleNbr;

			struct a2v
			{
				float4 vertex:POSITION;
				float4 texcoord0:TEXCOORD0;
			};

			struct v2f
			{
				float4 position:SV_POSITION;
				float4 texcoord0:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 color;
				float distanceToCenter;
				float time = _Time.x*_Speed;

				float xDist = _OrigineX - i.texcoord0.x;
				float yDist = _OrigineY - i.texcoord0.y;

				distanceToCenter = (xDist*xDist+ yDist*yDist)*_CircleNbr;

				color = sin(atan2(xDist,yDist) * _CircleNbr + time);

				return color;
			}


			ENDCG
		}
	}
}
