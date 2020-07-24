Shader "ObjectEffect/S_RememberBrush"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" { }
		_NoiseTex ("Noise Tex", 2D) = "white" { }
		_MaskTex ("Mask Tex", 2D) = "white" { }
		_SpectumAmount ("Spectum Amount", Range(0, 1)) = 0.1
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0.0
		
		_LineAlpha ("Line Alpha", Range(0, 1)) = 0.5
		_LineStrengh ("Line Strengh", Vector) = (7.5, 0.5, 0.0)
		_LineUVOffset ("UVMoveSpeed", Vector) = (0, 0, 0, 0)
		_Freq ("Freq", float) = 1
		_Angle ("Angle", Range(0, 6.28)) = 0
		
		[Toggle(USE_OUTLINE)]_UseOutLine ("UseOutLine", float) = 0
	}
	SubShader
	{
		
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		
		CGPROGRAM
		
		#pragma surface surf Standard fullforwardShadows
		#pragma target 3.0
		
		struct Input
		{
			float2 uv_MainTex;
		};
		
		sampler2D _MainTex;
		half _Glossiness, _Metallic;
		half4 _Color;
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		
		ENDCG
		
		Pass
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			
			
			Blend One One
			
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature USE_OUTLINE
			
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
				float3 normal: NORMAL;
				float4 wpos: TEXCOORD1;
			};
			
			sampler2D _MainTex, _MaskTex, _NoiseTex;
			float4 _NoiseTex_ST;
			half _Glossiness, _Metallic, _LineAlpha, _Freq, _Angle;
			half4 _Color;
			half4 _LineUVOffset, _LineStrengh;
			float _SpectumAmount;
			
			inline float OffsetT()
			{
				return sign(sin(_Time.y * 3.14 * _Freq));
			}
			
			inline float2x2 MATRIX_2(float angle)
			{
				return float2x2(cos(angle), -sin(angle),
				sin(angle), cos(angle));
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				v.vertex.xyz += normalize(v.vertex.xyz) * _SpectumAmount;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half mask = tex2D(_MaskTex, i.uv).r;
				
				#if USE_OUTLINE
					half3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
					half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
					half rim = 1 - saturate(dot(worldNormal, worldViewDir));
					
					//描边
					rim = pow(rim, 4);
					rim = step(0.5, rim);
					rim *= 4;
					//return rim;
				#endif
				
				//UV偏移动画
				float2 offset = _LineUVOffset.xy * OffsetT();
				float2 vec = i.uv - float2(0.5, 0.5);
				i.uv.xy = float2(0.5, 0.5) + mul(MATRIX_2(_Angle), vec);
				//将UV拉伸 , 形成笔触线条
				i.uv *= _LineStrengh.xy;
				half4 noiseCol = tex2D(_NoiseTex, i.uv + offset.xy);
				#if USE_OUTLINE
					noiseCol.rgb = smoothstep(0.75, 0.95, noiseCol.rgb * 2) + smoothstep(0.4, 0.9, rim * noiseCol);
				#else
					noiseCol.rgb = smoothstep(0.75, 0.95, noiseCol.rgb * 2);
				#endif
				return noiseCol * _LineAlpha * mask;
			}
			
			ENDCG
			
		}
	}
}
