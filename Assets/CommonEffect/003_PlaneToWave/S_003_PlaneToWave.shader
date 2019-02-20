Shader "CommonEffect/S_003_PlaneToWave"
{
	Properties
	{
		_Color("Color",Color) = (0,0,0,1)
		_Amplitude("Amplitude",Range(0,4)) = 1.0
		_Movement("Movement",Range(-100,100)) = 0
	}
	SubShader
	{
		Tags {"RenderType"="transparent"}

		Pass
		{
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;
			float _Amplitude;
			float _Movement;
			float _Scale;

			struct a2v
			{
				float4 vertex:POSITION;
			};

			struct v2f
			{
				float4 pos:sv_position;
			};

			v2f vert(a2v v)
			{
				v2f o;

				float4 posWorld = mul(unity_ObjectToWorld,v.vertex);

				float displacement= /*cos(posWorld.y)+*/cos(posWorld.x +_Movement*_Time.x);

				posWorld.y = posWorld.y + _Amplitude*displacement;

				o.pos = mul(UNITY_MATRIX_VP,posWorld);

				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				return _Color;
			}


			ENDCG
		}
	}
}
