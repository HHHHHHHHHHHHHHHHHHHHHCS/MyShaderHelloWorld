Shader "GrabPass/S_Cloaking"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Cut ("Cut", Range(0, 1)) = 0.1
		_Distort ("Distort", float) = 60
	}
	SubShader
	{
		
		GrabPass
		{
			"_GrabTex"
		}
		
		Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf SS finalcolor:FinalC
		#pragma target 3.0
		
		sampler2D _GrabTex;
		float2 _GrabTex_TexelSize;
		float _Cut, _Distort;
		
		struct Input
		{
			float4 screenPos;
		};
		
		fixed4 _Color;
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _Color.rgb;
		}
		
		fixed4 LightingSS(inout SurfaceOutput o, half3 lightDir, half3 viewDir, float atten)
		{
			//需要比较自如的控制边框的粗细，这里pow的次数需要小一点。主要
			//通过smoothstep来控制粗细。
			float alpha = pow(1 - saturate(dot(viewDir, o.Normal)), 2);
			alpha = smoothstep(_Cut * (1 - 0.5), _Cut * (1 + 0.5), alpha);
			float3 diff = alpha * o.Albedo;
			return fixed4(diff, alpha);
		}
		
		void FinalC(Input IN, SurfaceOutput o, inout fixed4 col)
		{
			//伪折射
			IN.screenPos.xy /= IN.screenPos.w;
			IN.screenPos.xy += o.Normal.xy * _GrabTex_TexelSize.xy * _Distort;
			fixed3 c = tex2D(_GrabTex, IN.screenPos.xy).xyz;
			col.xyz = lerp(c, o.Albedo, col.a);
		}
		
		ENDCG
		
	}
}