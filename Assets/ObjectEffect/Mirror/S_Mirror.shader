Shader "ObjectEffect/S_Mirror" 
{
	Properties 
	{
		_MainTex("Main Tex",2D)="white"{}
		
	}
	SubShader
	{
		pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;

			struct a2v
			{
				float4 vertex:POSITION;
				fixed2 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed2 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv=v.texcoord;
				o.uv.x=1-o.uv.x;

				return o;
			}

			fixed4 frag(v2f i):SV_TARGET
			{
				return tex2D(_MainTex,i.uv);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
