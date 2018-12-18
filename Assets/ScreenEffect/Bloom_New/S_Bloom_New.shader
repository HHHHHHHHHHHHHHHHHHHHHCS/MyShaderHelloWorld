Shader "HCS/S_Bloom_New" 
{
	Properties 
	{
		_MainTex("Texture",2D)="white"{}
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex,_SourceTex;
		float4 _MainTex_TexelSize;
		float _Intensity ;
		half4 _Filter;

		struct a2v
		{
			float4 vertex :POSITION;
			float2 uv :TEXCOORD0;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		half3 Sample(float2 uv)
		{
			return tex2D(_MainTex,uv).rgb;
		}

		half3 SampleBox(float2 uv,float delta)
		{
			float4 o = _MainTex_TexelSize.xyxy*float2(-delta,delta).xxyy;
			half3 s = Sample(uv+o.xy)+Sample(uv+o.zy)
				+Sample(uv+o.xw)+Sample(uv+o.zw);
				return s/4;
		}

		half3 Prefilter(half3 c)
		{
			half brightness = max(c.r, max(c.g, c.b));
			half soft = brightness - _Filter.y;
			soft = clamp(soft, 0, _Filter.z);
			soft = soft * soft * _Filter.w;
			half contribution = max(soft, brightness - _Filter.x);
			contribution /= max(brightness, 0.00001);
			return c * contribution;
		}

		v2f vert(a2v i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.uv;
			return o;
		}

	ENDCG	

	SubShader 
	{
		Cull Off
		ZTest Always
		ZWrite Off

		pass
		{//亮度颜色校准用
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


				half4 frag(v2f i):SV_TARGET
				{
					return half4(Prefilter(SampleBox(i.uv,1)),0);
				}

			ENDCG
		}

		pass
		{//模糊用
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


				half4 frag(v2f i):SV_TARGET
				{
					return half4(SampleBox(i.uv,1),0);
				}

			ENDCG
		}

		pass
		{//向上清晰用   包括颜色组合
			Blend One One

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


				half4 frag(v2f i):SV_TARGET
				{
					return half4(SampleBox(i.uv,0.5),1);
				}

			ENDCG
		}

		pass
		{//原图叠加上去
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				half4 frag(v2f i):SV_TARGET
				{
					half4 c= tex2D(_SourceTex,i.uv);
					c.rgb+=_Intensity*SampleBox(i.uv,0.5);
					return c;
				}

			ENDCG
		}

		pass 
		{//测试用 
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				half4 frag (v2f i) : SV_Target {
					return _Intensity*half4(SampleBox(i.uv, 0.5), 1);
				}
			ENDCG
		}
	}
}
