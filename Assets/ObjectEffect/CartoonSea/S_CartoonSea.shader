Shader "ObjectEffect/S_CartoonSea"
{
	Properties
	{
		_LightPos ("Light Pos", Vector) = (0, 1, 0, 0)
		
		_MainTex ("Main Texture", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100
		
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldNormal: TEXCOORD1;
				float4 projPos: TEXCOORD2;
				float3 worldPos: TEXCOORD3;
				UNITY_FOG_COORDS(4)
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LightPos;
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			
			half4 CosineGradient(float x, half4 phase, half4 amp, half4 freq, half4 offset)
			{
				phase *= UNITY_TWO_PI;
				x *= UNITY_TWO_PI;
				
				return half4(
					offset.r + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
					offset.g + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
					offset.b + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
					offset.a + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
				);
			}
			
			float2 Rand(float2 st, int seed)
			{
				float2 s = float2(dot(st, float2(127.1, 311.7)) + seed, dot(st, float2(269.5, 183.3)) + seed);
				return - 1 + 2 * frac(sin(s) * 43758.5453123);
			}
			
			float Noise(float2 st, int seed)
			{
				st.y += _Time[1];
				
				float2 p = floor(st);
				float2 f = frac(st);
				
				float w00 = dot(Rand(p, seed), f);
				float w10 = dot(Rand(p + float2(1, 0), seed), f - float2(1, 0));
				float w01 = dot(Rand(p + float2(0, 1), seed), f - float2(0, 1));
				float w11 = dot(Rand(p + float2(1, 1), seed), f - float2(1, 1));
				
				float2 u = f * f * (3 - 2 * f);
				
				return lerp(lerp(w00, w10, u.x), lerp(w01, w11, u.x), u.y);
			}
			
			float3 Swell(float3 normal, float3 pos, float anisotropy)
			{
				float height = Noise(pos.xz * 0.1, 0.0);
				height *= anisotropy;
				normal = normalize(
					cross(float3(0, ddy(height), 1), float3(1, ddx(height), 0))
				);
				return normal;
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.vertex);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.projPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				
				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float volmeZ = saturate((sceneZ - partZ) / 10.0f);
				
				const half4 phases = half4(0.28, 0.50, 0.07, 0.);
				const half4 amplitudes = half4(4.02, 0.34, 0.65, 0.);
				const half4 frequencies = half4(0.00, 0.48, 0.08, 0.);
				const half4 offsets = half4(0.00, 0.16, 0.00, 0.);
				
				half4 cos_grad = CosineGradient(1 - volmeZ, phases, amplitudes, frequencies, offsets);
				cos_grad = saturate(cos_grad);
				col.rgb = cos_grad.rgb;
				
				half3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				float3 v = i.worldPos - _WorldSpaceCameraPos;
				//越远越小
				float anisotropy = saturate((1 / ddy(length(v.xz))) / 5);
				//波纹起来后的normal
				float3 swelledNormal = Swell(i.worldNormal, i.worldPos, anisotropy);
				
				half3 reflDir = reflect(-worldViewDir, swelledNormal);
				half4 reflectionColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir,0);
				
				//main Light
				float spe = pow(saturate(dot(reflDir, normalize(UnityWorldSpaceLightDir(i.worldPos)))), 100);
				half4 lightColor = half4(unity_LightColor0.rgb, 1.0);
				reflectionColor += 0.4 * half4((spe * lightColor).xxxx);
				
				//fresnel
				float f0 = 0.02;
				float vReflect = f0 + (1 - f0) *
				pow(1 - dot(worldViewDir, swelledNormal), 5);
				vReflect = saturate(vReflect * 2.0);
				
				col = lerp(col, reflectionColor, vReflect);
				
				col.a = saturate(volmeZ);
				
				
				return col;
			}
			ENDCG
			
		}
	}
}
