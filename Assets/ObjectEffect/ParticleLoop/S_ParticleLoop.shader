Shader "ObjectEffect/S_ParticleLoop"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_TimeOffset ("Noise Offset", Range(0, 20)) = 10
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
		LOD 100
		
		Blend One One // 加法混合
		ZWrite Off //关闭深度写入
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				half3 normal: NORMAL;
				fixed4 color: COLOR;
				float4 uv0: TEXCOORD0;
				float4 uv1: TEXCOORD1;
				float4 uv2: TEXCOORD2;
				float4 uv3: TEXCOORD3;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				half4 color: COLOR;
				float4 uv0: TEXCOORD0;
				float4 uv1: TEXCOORD1;
				float4 uv2: TEXCOORD2;
				float4 uv3: TEXCOORD3;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			uniform float _TimeOffset;
			
			v2f vert(appdata v)
			{
				v2f o;
				
				float sinFrequency = 5.0;
				float sinAmplitude = 4.0;
				
				float time = _Time.y + _TimeOffset;
				float sinOffset = sin(time * sinFrequency) * sinAmplitude;
				float agePercent = v.uv0.z;
				
				float3 vertexOffset = float3(0, sinOffset * agePercent, 0);
				v.vertex.xyz += vertexOffset;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv0.xy = TRANSFORM_TEX(v.uv0.xy, _MainTex);
				o.uv0.zw = v.uv0.zw;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv0.xy);
				
				col *= i.color;
				
				float particleAgePercent = i.uv0.z;
				half4 colorRed = half4(1, 0, 0, 1);
				
				col = lerp(col, colorRed * col.a, particleAgePercent);
				
				return col;
			}
			ENDCG
			
		}
	}
}
