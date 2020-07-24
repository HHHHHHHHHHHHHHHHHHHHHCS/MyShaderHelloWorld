Shader "ScreenEffect/S_LensFlare_GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BlurSize ("Blur Size", float) = 8
		_Sigma ("Sigma", float) = 3
		_Direction ("Direction", int) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		
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
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurSize;
			float _Sigma;
			int _Direction;
			
			inline float g(float x)
			{
				return pow(2.71829, -x * x / (2 * _Sigma * _Sigma)) / sqrt(2 * 3.141593 * _Sigma * _Sigma);
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 col = half4(0, 0, 0, 0);
				for (int k = -_BlurSize; k <= _BlurSize; k ++)
				{
					col += tex2D(_MainTex, i.uv + float2(_Direction * k * _MainTex_TexelSize.x, (1 - _Direction) * k * _MainTex_TexelSize.y)) * g(k);
				}
				col.a = 1;
				return col;
			}
			
			ENDCG
			
		}
	}
}
