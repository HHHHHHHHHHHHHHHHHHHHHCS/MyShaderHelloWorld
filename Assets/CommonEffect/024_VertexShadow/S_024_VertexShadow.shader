Shader "CommonEffect/S_024_VertexShadow"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float4 pos:SV_POSITION;
				LIGHTING_COORDS(0,1)//TEXCOORD0 和 TEXCOORD1
			};

			fixed4 _Color;
			fixed4 _LightColor0;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);//顶点转换到片元
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				float attenuation = LIGHT_ATTENUATION(i);//阴影的强度
				return _Color*attenuation*_LightColor0;
			}

			ENDCG
		}
	}

	Fallback "VertexLit"//别忘记这个 
}
