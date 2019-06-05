Shader "CommandEffect/S_032_VolumetericSphere"
{
	Properties
	{
		_Center ("Center", vector) = (0, 0, 0, 0)
		_ColorCube ("Color Cube", Color) = (1, 1, 1, 1)
		_ColorSphere ("Color Sphere", Color) = (1, 1, 1, 1)
		_Radius ("Radius", float) = 2.0
		_StepNumber ("Step Number", float) = 10.0
		_StepVal ("Step Val", float) = 0.1
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" }
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldPos: TEXCOORD1;
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			float _StepNumber;
			float _StepVal;
			float3 _Center;
			float _Radius;
			half4 _ColorCube;
			half4 _ColorSphere;
			
			half4 rayMarch(float3 worldPos, float viewDirection)
			{
				for (int i = 0; i < _StepNumber; i ++)
				{
					if (distance(worldPos, _Center) < _Radius)
					{
						return _ColorSphere;
					}
					worldPos += viewDirection * _StepVal;
				}
				return _ColorCube;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				float3 viewDirection = normalize(i.worldPos - _WorldSpaceCameraPos);
				return rayMarch(i.worldPos, viewDirection);
			}
			
			
			ENDCG
			
		}
	}
}
