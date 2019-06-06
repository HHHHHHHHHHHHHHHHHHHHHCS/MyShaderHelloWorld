Shader "CommonEffect/S_035_DeformModel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_ControlPoint ("Control point", vector) = (1, 1, 1, 1)
	}
	SubShader
	{
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
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _ControlPoint;
			
			
			v2f vert(appdata_base v)
			{
				v2f o;
				float3 begin = float3(-0.5, v.vertex.y, v.vertex.z);
				float3 end = float3(0.5, v.vertex.y, v.vertex.z);
				
				float vertX = v.vertex.x + 0.5;
				
				float x = v.vertex.x;
				float y = v.vertex.y;
				float z = v.vertex.z;
				
				float3 temp;

				//temp = (1 - vertX) * (1 - vertX) * begin.xyz
				//+ 2.0 * (1 - vertX) * vertX * _ControlPoint.xyz
				//+ vertX * vertX * end.xyz;
				
				temp.x = x;
				temp.y = y * (2 * x * x + 0.5);
				temp.z = z * (2 * x * x + 0.5);
				
				temp.xyz += (0.5-2*x*x)* _ControlPoint.xyz;

				
				o.pos = UnityObjectToClipPos(temp);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag(v2f i): SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
			
		}
	}
}
