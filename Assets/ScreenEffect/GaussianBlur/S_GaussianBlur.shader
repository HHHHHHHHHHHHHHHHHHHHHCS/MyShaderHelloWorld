Shader "HCS/GaussianBlur" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv[5]:TEXCOORD0;
		};

		v2f vertBlurVertical(appdata_img v)
		{
			v2f o;

			o.pos=UnityObjectToClipPos(v.vertex);

			half2 uv=v.texcoord;

			o.uv[0]=uv;
			o.uv[1]=uv+float2(0,_MainTex_TexelSize.y*1)* _BlurSize;
			o.uv[2]=uv-float2(0,_MainTex_TexelSize.y*1)* _BlurSize;
			o.uv[3]=uv+float2(0,_MainTex_TexelSize.y*2)* _BlurSize;
			o.uv[4]=uv-float2(0,_MainTex_TexelSize.y*2)* _BlurSize;

			return o;
		}

				
		v2f vertBlurHorizontal(appdata_img v) 
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			
			half2 uv = v.texcoord;
			
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
					 
			return o;
		}

		fixed4 fragBlur(v2f i):SV_TARGET
		{
			float weight[3]={0.4026,0.2442,0.0545};

			fixed3 sum=tex2D(_MainTex,i.uv[0])*weight[0];
			sum+=tex2D(_MainTex,i.uv[1])*weight[1];
			sum+=tex2D(_MainTex,i.uv[2])*weight[1];
			sum+=tex2D(_MainTex,i.uv[3])*weight[2];
			sum+=tex2D(_MainTex,i.uv[4])*weight[2];

			return fixed4(sum,1);
		}

		ENDCG

		ZTest Always Cull Off ZWrite Off

		pass
		{
			//name 记得大写  UNITY 会把name全部转换成大写
			//防止报错直接全部大写算了
			NAME "GAUSSIAN_BLUR_VERTICAL"

			CGPROGRAM

			#pragma vertex vertBlurVertical  
			#pragma fragment fragBlur

			ENDCG
		}

		pass
		{
			NAME "GAUSSIAN_BLUR_HORIZONTAL"

			CGPROGRAM

			#pragma vertex vertBlurHorizontal  
			#pragma fragment fragBlur

			ENDCG
		}
	}
	FallBack "Diffuse"
}
