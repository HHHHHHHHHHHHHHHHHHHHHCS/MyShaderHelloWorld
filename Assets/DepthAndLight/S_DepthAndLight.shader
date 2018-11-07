Shader "HCS/S_DepthAndLight"
{
    Properties
    {
		_MainTex("Texture",2D)="white"{}
    }

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex,_CameraDepthNormalsTexture;
		half2 _MainTex_TexelSize;

		struct a2v
		{
			float4 vertex:POSITION;
			float2 uv:TEXCOORD;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		
		v2f vert(a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;

			return o;
		}

	ENDCG

    SubShader
    {
		Cull off
		ZTest Always
		ZWrite off

		pass
		{// 0 depth 

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			int CheckSampe(half4 center,half4 sample)
			{
				#define lessthan 0.1

				half2 centerNormal = center.xy;
				float2 centerDepth = DecodeFloatRG(center.zw);
				half2 sampleNormal = sample.xy;
				float2 sampleDepth = DecodeFloatRG(sample.zw);

				half2 diffNormal = abs(centerNormal-sampleNormal);
				int isSameNormal = (diffNormal.x+diffNormal.y)<lessthan;

				float2 diffDepth = abs(centerDepth-sampleDepth);
				int isSameDepth = diffDepth<lessthan*centerDepth;

				return isSameNormal*isSameDepth?1:0;
			}

			float4 CheckEdge(float2 uv0)
			{
				#define jump 1
				half2 offest = half2(1,-1);

				half2 uv1=uv0+_MainTex_TexelSize.xy*offest.xx*jump;
				half2 uv2=uv0+_MainTex_TexelSize.xy*offest.xy*jump;
				half2 uv3=uv0+_MainTex_TexelSize.xy*offest.yx*jump;
				half2 uv4=uv0+_MainTex_TexelSize.xy*offest.yy*jump;

				half4 sample1=tex2D(_CameraDepthNormalsTexture,uv1);
				half4 sample2=tex2D(_CameraDepthNormalsTexture,uv2);
				half4 sample3=tex2D(_CameraDepthNormalsTexture,uv3);
				half4 sample4=tex2D(_CameraDepthNormalsTexture,uv4);

				int edge = CheckSampe(sample1,sample4)*CheckSampe(sample2,sample3);

				return edge;
			}

			half4 frag(v2f i):SV_TARGET
			{
				return CheckEdge(i.uv);
			}

			ENDCG
		}

		pass
		{// 1 light 
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			float4 frag(v2f i):SV_TARGET
			{
				float4 sample = tex2D(_MainTex, i.uv);
				sample.rgb = saturate(sample.rgb);
				sample.a = LinearRgbToLuminance(sample.rgb);
				return sample.a;
			}

			ENDCG
		}

		pass
		{// 2 mix
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			float4 frag(v2f i):SV_TARGET
			{
				half4 sample = tex2D(_MainTex, i.uv);
				sample.rgb = saturate(sample.rgb);
				sample.a = LinearRgbToLuminance(sample.rgb);
				return sample.a;
			}

			ENDCG
		}
	}
}
