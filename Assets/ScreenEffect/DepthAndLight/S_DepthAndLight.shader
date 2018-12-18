Shader "HCS/S_DepthAndLight"
{

    Properties
    {
		_MainTex("Texture",2D)="white"{}
    }

	CGINCLUDE
		#define lessthan 0.1
		#define edgeJump 1
		#define bloomJump 5

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
		{// 0 边缘彩色

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag


			int CheckSampe(half4 center,half4 sample)
			{
				half2 centerNormal = center.xy;
				float centerDepth = DecodeFloatRG(center.zw);
				half2 sampleNormal = sample.xy;
				float sampleDepth = DecodeFloatRG(sample.zw);

				half2 diffNormal = abs(centerNormal-sampleNormal);
				int isSameNormal = (diffNormal.x+diffNormal.y)<lessthan;

				float diffDepth = abs(centerDepth-sampleDepth);
				int isSameDepth = diffDepth<lessthan*centerDepth;

				return isSameNormal*isSameDepth?1:0;
			}

			float4 CheckEdge(float2 uv0)
			{

				half2 offest = half2(1,-1);

				half2 uv1=uv0+_MainTex_TexelSize.xy*offest.xx*edgeJump;
				half2 uv2=uv0+_MainTex_TexelSize.xy*offest.xy*edgeJump;
				half2 uv3=uv0+_MainTex_TexelSize.xy*offest.yx*edgeJump;
				half2 uv4=uv0+_MainTex_TexelSize.xy*offest.yy*edgeJump;

				half4 sample1=tex2D(_CameraDepthNormalsTexture,uv1);
				half4 sample2=tex2D(_CameraDepthNormalsTexture,uv2);
				half4 sample3=tex2D(_CameraDepthNormalsTexture,uv3);
				half4 sample4=tex2D(_CameraDepthNormalsTexture,uv4);

				int edge = CheckSampe(sample1,sample4)*CheckSampe(sample2,sample3);

				return edge;
			}

			float4 CalcLight(v2f i)
			{
				float4 sample = tex2D(_MainTex, i.uv);
				sample.rgb = saturate(sample.rgb);
				sample.a = LinearRgbToLuminance(sample.rgb);
				return sample;
			}

			half3 MixedTexture(v2f i)
			{
				float edge = 1 - CheckEdge(i.uv);
				edge*=CalcLight(i).a;
				return edge*CalcLight(i).rgb;
			}


			half3 frag(v2f i):SV_TARGET
			{
				return MixedTexture(i);
			}

			ENDCG
		}

		pass
		{// 1 边缘颜色扩散
			CGPROGRAM

				sampler2D _OutlineTexture;

				#pragma vertex vert
				#pragma fragment frag
				
				half3 CheckOut(v2f i)
				{
					float4 center = tex2D(_CameraDepthNormalsTexture,i.uv);
					float centerDepth = DecodeFloatRG(center.zw);
					float centerCol = tex2D(_OutlineTexture,i.uv);
					if(centerDepth>0.99999 && centerCol.r==0)
					{
						float3 offest = float3(0,1,-1);

						float2 uv1 = i.uv+_MainTex_TexelSize*offest.xy*bloomJump;
						float2 uv2 = i.uv+_MainTex_TexelSize*offest.xz*bloomJump;
						float2 uv3 = i.uv+_MainTex_TexelSize*offest.yx*bloomJump;
						float2 uv4 = i.uv+_MainTex_TexelSize*offest.zx*bloomJump;
						float2 uv5 = i.uv+_MainTex_TexelSize*offest.yy*bloomJump;
						float2 uv6 = i.uv+_MainTex_TexelSize*offest.zz*bloomJump;
						float2 uv7 = i.uv+_MainTex_TexelSize*offest.yz*bloomJump;
						float2 uv8 = i.uv+_MainTex_TexelSize*offest.zy*bloomJump;

						float3 col0 = 0.15*(tex2D(_OutlineTexture,uv1) + tex2D(_OutlineTexture,uv2) + tex2D(_OutlineTexture,uv3) + tex2D(_OutlineTexture,uv4))
							+ 0.1*(tex2D(_OutlineTexture,uv5) + tex2D(_OutlineTexture,uv6) + tex2D(_OutlineTexture,uv7) + tex2D(_OutlineTexture,uv8));

						if(col0.r==0)
						{
							return 0;
						}

						float3 col1 = 0.15*(tex2D(_MainTex,uv1) + tex2D(_MainTex,uv2) + tex2D(_MainTex,uv3) + tex2D(_MainTex,uv4))
							+ 0.1*(tex2D(_MainTex,uv5) + tex2D(_MainTex,uv6) + tex2D(_MainTex,uv7) + tex2D(_MainTex,uv8));

						return col1;
					}

					return 0;
				}

				half3 frag(v2f i):SV_TARGET
				{
					return CheckOut(i)+tex2D(_MainTex,i.uv);
				}

			ENDCG
		}
	}
}
