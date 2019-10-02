Shader "HCS/S_LensFlare_Bloom"
{
	Properties
	{
		_MainTex ("", 2D) = "" { }
		_BasetTex ("", 2D) = "" { }
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	//手机:使用RGBM 代替 float/half RGB
	#define USE_RGBM defined(SHADER_API_MOBILE)
	
	sampler2D _MainTex;
	sampler2D _BaseTex;
	float2 _MainTex_TexelSize;
	float2 _BaseTex_TexelSize;
	half4 _MainTex_ST;
	half4 _BaseTex_ST;
	
	float _PrefilterOffs;
	half _Threshold;
	half3 _Curve;
	float _SampleScale;
	half _Intensity;
	
	sampler2D _DirtTex;
	half _DirtIntensity;
	
	//亮度  找出RGB中最大的值
	half Brightness(half3 c)
	{
		return max(max(c.r, c.g), c.b);
	}
	
	//得到出中间的颜色
	half3 Median(half3 a, half3 b, half3 c)
	{
		return a + b + c - min(a, min(b, c)) - max(a, max(b, c));
	}
	
	//限制HDR的值在安全范围内
	half3 SafeHDR(half3 c)
	{
		return min(c, 65000);
	}
	half4 SafeHDR(half4 c)
	{
		return min(c, 65000);
	}
	
	//压缩HDR
	half4 EncodeHDR(float3 rgb)
	{
		#if USE_RGBM
			rgb *= 1.0 / 8;
			float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
			m = ceil(m * 255) / 255;
			return half4(rgb / m, m);
		#else
			return half4(rgb, 0);
		#endif
	}
	
	//解压HDR
	float3 DecodeHDR(half4 rgba)
	{
		#if USE_RGBM
			return rgba.rgb * rgb.a * 8;
		#else
			return rgba.rgb;
		#endif
	}
	
	//降采样 用 4x4 box 滤波
	half3 DownsampleFilter(float2 uv)
	{
		float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, 1, 1);
		half3 s;
		s = DecodeHDR(tex2D(_MainTex, uv + d.xy));
		s += DecodeHDR(tex2D(_MainTex, uv + d.zy));
		s += DecodeHDR(tex2D(_MainTex, uv + d.xw));
		s += DecodeHDR(tex2D(_MainTex, uv + d.zw));
		
		return s * (1.0 / 4);
	}
	
	//降采样  平滑高亮
	half3 DownsampleAntiFlickerFilter(float2 uv)
	{
		float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, 1, 1);
		half3 s1 = DecodeHDR(tex2D(_MainTex, uv + d.xy));
		half3 s2 = DecodeHDR(tex2D(_MainTex, uv + d.zy));
		half3 s3 = DecodeHDR(tex2D(_MainTex, uv + d.xw));
		half3 s4 = DecodeHDR(tex2D(_MainTex, uv + d.zw));
		
		half s1w = 1 / (Brightness(s1) + 1);
		half s2w = 1 / (Brightness(s2) + 1);
		half s3w = 1 / (Brightness(s3) + 1);
		half s4w = 1 / (Brightness(s4) + 1);
		half one_div_wsum = 1 / (s1w + s2w + s3w + s4w);
		
		return(s1 * s1w + s2 * s2w + s3 * s3w + s4 * s4w) * one_div_wsum;
	}
	
	//升采样 根据是否使用高质量,取周围的点 平均颜色
	half3 UpsampleFilter(float2 uv)
	{
		#if HIGH_QUALITY
			float4 = _MainTex_TexelSize.xyxy * float4(1, 1, -1, 0) * _SampleScale;
			
			half3 s;
			s = DecodeHDR(tex2D(_MainTex, uv - d.xy));
			s = DecodeHDR(tex2D(_MainTex, uv - d.wy)) * 2;
			s = DecodeHDR(tex2D(_MainTex, uv - d.zy));
			
			s = DecodeHDR(tex2D(_MainTex, uv + d.zw)) * 2;
			s = DecodeHDR(tex2D(_MainTex, uv)) * 4;
			s = DecodeHDR(tex2D(_MainTex, uv + d.xw)) * 2;
			
			s = DecodeHDR(tex2D(_MainTex, uv + d.zy));
			s = DecodeHDR(tex2D(_MainTex, uv + d.wy)) * 2;
			s = DecodeHDR(tex2D(_MainTex, uv + d.xy));
			
			return s * (1.0 / 16);
		#else
			float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, 1, 1) * (_SampleScale * 0.5);
			
			half3 s;
			s = DecodeHDR(tex2D(_MainTex, uv + d.xy));
			s += DecodeHDR(tex2D(_MainTex, uv + d.zy));
			s += DecodeHDR(tex2D(_MainTex, uv + d.xw));
			s += DecodeHDR(tex2D(_MainTex, uv + d.zw));
			
			return s * (1.0 / 4);
		#endif
	}
	
	//vert shader
	v2f_img vert(appdata_img v)
	{
		v2f_img o;
		#if UNITY_VERSION >= 540
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
		#else
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
		#endif
		
		return o;
	}
	
	
	struct v2f_multitex
	{
		float4 pos: SV_POSITION;
		float2 uvMain: TEXCOORD0;
		float2 uvBase: TEXCOORD1;
	};
	
	v2f_multitex vert_multitex(appdata_img v)
	{
		v2f_multitex o;
		
		#if UNITY_VERSION >= 540
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uvMain = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
			o.uvBase = UnityStereoScreenSpaceUVAdjust(v.texcoord, _BaseTex_ST);
		#else
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uvMain = v.texcoord;
			o.uvBase = v.texcoord;
		#endif
		
		#if UNITY_UV_STARTS_AT_TOP
			if (_BaseTex_TexelSize.y < 0.0)
				o.uvBase.y = 1.0 - v.texcoord.y;
		#endif
		
		return o;
	}
	
	//frag shader
	half4 frag_prefilter(v2f_img i): SV_TARGET
	{
		float2 uv = i.uv + _MainTex_TexelSize.xy * _PrefilterOffs;
		
		#if ANTI_FLICKER
			float3 d = _MainTex_TexelSize.xyx * float3(1, 1, 0);
			half4 s0 = SafeHDR(tex2D(_MainTex, uv));
			half3 s1 = SafeHDR(tex2D(_MainTex, uv - d.xz).rgb);
			half3 s2 = SafeHDR(tex2D(_MainTex, uv + d.xz).rgb);
			half3 s3 = SafeHDR(tex2D(_MainTex, uv - d.zy).rgb);
			half3 s4 = SafeHDR(tex2D(_MainTex, uv + d.zy).rgb);
			half3 m = Median(Median(s0.rgb, s1, s2), s3, s4);
		#else
			half4 s0 = SafeHDR(tex2D(_MainTex, uv));
			half3 m = s0.rgb;
		#endif
		
		#if UNITY_COLORSPACE_GAMMA
			m = GammaToLinearSpace(m);
		#endif
		
		//选出最亮的
		half br = Brightness(m);
		
		//卷积过渡
		half rq = clamp(br - _Curve.x, 0, _Curve.y);
		rq = _Curve.z * rq * rq;
		
		//亮度阀值
		m *= max(rq, br - _Threshold) / max(br, 1e-5);
		
		return EncodeHDR(m);
	}
	
	
	half4 frag_downsample1(v2f_img i): SV_Target
	{
		#if ANTI_FLICKER
			return EncodeHDR(DownsampleAntiFlickerFilter(i.uv));
		#else
			return EncodeHDR(DownsampleFilter(i.uv));
		#endif
	}
	
	half4 frag_downsample2(v2f_img i): SV_Target
	{
		return EncodeHDR(DownsampleFilter(i.uv));
	}
	
	
	half4 frag_upsample(v2f_multitex i): SV_Target
	{
		half3 base = DecodeHDR(tex2D(_BaseTex, i.uvBase));
		half3 blur = UpsampleFilter(i.uvMain);
		return EncodeHDR(base + blur);
	}
	
	
	half4 frag_upsample_final(v2f_multitex i): SV_Target
	{
		half4 base = tex2D(_BaseTex, i.uvBase);
		half3 blur = UpsampleFilter(i.uvMain);
		#if UNITY_COLORSPACE_GAMMA
			base.rgb = GammaToLinearSpace(base.rgb);
		#endif
		half3 bloom = blur * _Intensity;
		half3 cout = base.rgb + bloom;
		#if DIRT_TEXTURE
			half3 dirt = tex2D(_DirtTex, i.uvMain).rgb * _DirtIntensity;
			cout += bloom * dirt;
		#endif
		#if UNITY_COLORSPACE_GAMMA
			cout = LinearToGammaSpace(cout);
		#endif
		return half4(cout, base.a);
	}
	
	ENDCG
	
	SubShader
	{
		// 0: Prefilter
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag_prefilter
			#pragma target 3.0
			ENDCG
			
		}
		// 1: Prefilter with anti-flicker
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define ANTI_FLICKER 1

			#pragma vertex vert
			#pragma fragment frag_prefilter
			#pragma target 3.0
			ENDCG
			
		}
		// 2: First level downsampler
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag_downsample1
			#pragma target 3.0
			ENDCG
			
		}
		// 3: First level downsampler with anti-flicker
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define ANTI_FLICKER 1
			#pragma vertex vert
			#pragma fragment frag_downsample1
			#pragma target 3.0
			ENDCG
			
		}
		// 4: Second level downsampler
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag_downsample2
			#pragma target 3.0
			ENDCG
			
		}
		// 5: Upsampler
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert_multitex
			#pragma fragment frag_upsample
			#pragma target 3.0
			ENDCG
			
		}
		// 6: High quality upsampler
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define HIGH_QUALITY 1

			#pragma vertex vert_multitex
			#pragma fragment frag_upsample
			#pragma target 3.0
			ENDCG
			
		}
		// 7: Combiner
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert_multitex
			#pragma fragment frag_upsample_final
			#pragma target 3.0
			ENDCG
			
		}
		// 8: High quality combiner
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define HIGH_QUALITY 1

			#pragma vertex vert_multitex
			#pragma fragment frag_upsample_final
			#pragma target 3.0
			ENDCG
			
		}
		// 9: Combiner + dirt texture
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define DIRT_TEXTURE 1

			#pragma vertex vert_multitex
			#pragma fragment frag_upsample_final
			#pragma target 3.0
			ENDCG
			
		}
		// 10: High quality combiner + dirt texture
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#define DIRT_TEXTURE 1
			#define HIGH_QUALITY 1

			#pragma vertex vert_multitex
			#pragma fragment frag_upsample_final
			#pragma target 3.0
			ENDCG
		}
	}
}
