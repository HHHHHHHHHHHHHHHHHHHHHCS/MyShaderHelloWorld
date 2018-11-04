Shader "HCS/s_FXAA"
{
    Properties
    {
		_MainTex("Texture",2D)="white"{}
    }

	CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;

		struct a2v 
		{
			float4 vertex:POSITION;
			float2 uv :TEXCOORD0;
		};

		struct v2f
		{
			float4 pos :SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		struct LuminanceData
		{
			float m,n,e,s,w;
			float higest,lowest,contrast;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv=v.uv;
			return o;
		}

		float4 Sample(float2 uv)
		{
			return tex2D(_MainTex,uv);
		}

		float SampleLuminance(float2 uv)
		{
			#if defined(LUMINANCE_GREEN)
				return Sample(uv).g;
			#else
				return Sample(uv).a;
			#endif
		}
		
		float SampleLuminance(float2 uv,float uOffset,float vOffset)
		{
			uv+=_MainTex_TexelSize*float2(uOffset,vOffset);
			return SampleLuminance(uv);
		}

		LuminanceData SampleLuminanceNeighborhood(float2 uv)
		{ 
			LuminanceData l;
			l.m=SampleLuminance(uv);
			l.n=SampleLuminance(uv,0,1);
			l.e=SampleLuminance(uv,1,0);
			l.s=SampleLuminance(uv,0,-1);
			l.w=SampleLuminance(uv,-1,0);


			l.higest=max(max(max(max(l.n,l.e),l.s),l.w),l.m);
			l.lowest=min(min(min(min(l.n,l.e),l.s),l.w),l.m);
			l.contrast=l.higest-l.lowest;

			return l;
		}
		

		float4 ApplyFXAA(float2 uv)
		{
			LuminanceData l = SampleLuminanceNeighborhood(uv);
			return l.contrast;
		}


	ENDCG

    SubShader
    {
		Cull off
		ZTest Always
		ZWrite off
		

		pass
		{// 0 lumiunancePass
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


				float4 frag(v2f i):SV_TARGET
				{
					float4 sample = tex2D(_MainTex,i.uv);
					sample.rgb = LinearRgbToLuminance(saturate(sample.rgb));
					return sample;
				}

				
			ENDCG
		}

		pass
		{// 1 fxaaPass
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#pragma multi_compile _ LUMINANCE_GREEN

				float4 frag(v2f i):SV_TARGET 
				{
					return ApplyFXAA(i.uv);
				}
			ENDCG
		}
	}
}
