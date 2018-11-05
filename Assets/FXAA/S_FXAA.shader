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
		float _ContrastThreshold,_RelativeThreshold;

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
			float ne,nw,se,sw;
			float higest,lowest,contrast;
		};

		struct EdgeData
		{
			bool isHorizontal;
			float pixelStep;
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

			l.ne=SampleLuminance(uv,1,1);
			l.nw=SampleLuminance(uv,-1,1);
			l.se=SampleLuminance(uv,1,-1);
			l.sw=SampleLuminance(uv,-1,-1);


			l.higest=max(max(max(max(l.n,l.e),l.s),l.w),l.m);
			l.lowest=min(min(min(min(l.n,l.e),l.s),l.w),l.m);
			l.contrast=l.higest-l.lowest;

			return l;
		}
		
		bool ShouldSkilPixel(LuminanceData l)
		{
			float threshold =max(_ContrastThreshold,_RelativeThreshold*l.higest);
			return l.contrast<l.contrast<threshold;
		}

		float DeterminePixelBlendFactor(LuminanceData l)
		{
			float filter = 2*(l.n+l.e+l.s+l.w);
			filter += l.ne+l.nw+l.se+l.sw;
			filter *= 1.0/12;
			filter = abs(filter-l.m);
			filter = saturate(filter/l.contrast);
			float blendFactor = smoothstep(0,1,filter);
			return blendFactor*blendFactor;
		}

		EdgeData DetermineEdge(LuminanceData l)
		{
			EdgeData e;
			float horizontal = 
				abs(l.n+l.s-2*l.m)*2+
				abs(l.ne+l.se-2*l.e)+
				abs(l.nw+l.sw-2*l.w);
			
			float vertical = 
				abs(l.e+l.w-2*l.m)*2+
				abs(l.ne+l.nw-2*l.n)+
				abs(l.se+l.sw-2*l.s);
			
			e.isHorizontal=horizontal>=vertical;
			return e;
		}


		float4 ApplyFXAA(float2 uv)
		{
			LuminanceData l = SampleLuminanceNeighborhood(uv);
			if(l.contrast<_RelativeThreshold*l.higest)
			{
				return 0;
			}

			float pixelBlend = DeterminePixelBlendFactor(l);
			EdgeData e = DetermineEdge(l);
			return e.isHorizontal?float4(1,0,0,0):1;
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
