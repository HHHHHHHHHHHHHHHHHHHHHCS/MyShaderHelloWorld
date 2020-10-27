Shader "ObjectEffect/S_WeaponOutline"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" { }
		_RampTex ("Ramp Texture", 2D) = "gray" { }
		
		[Header(Outline)]
		_NoiseTex ("Noise Texture", 2D) = "white" { }
		_OutlineScale ("Outline Scale", float) = 0.3
		_OutlineZ ("Outline Z Offset", Range(-0.06, 0)) = -1
		_XSpeed ("X Speed", float) = 1
		_YSpeed ("Y Speed", float) = 1
		_RimPower ("Rim Power", Range(-4, 10)) = 1
		_OffSet ("Noise Opacity", Range(0.01, 10)) = 1
		_Scale ("Scale", Range(0, 0.1)) = 0.01
		_Edge ("Edge", Range(0, 1)) = 1
		_Brightness ("Brightness", float) = 1
		_EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
		_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		LOD 100
		
		//需要加默认的原来的Pass
		
		
		//outline
		Pass
		{
			Name "Outline"
			Tags { "LightMode" = "Always" "Queue" = "Transparent" "RenderType" = "Transparent" }
			ZWrite Off
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 normalDir: TEXCOORD0;
				float3 viewDir: TEXCOORD2;
			};
			
			float _OutlineScale;
			float _OutlineZ;
			float _XSpeed, _YSpeed;
			sampler2D _NoiseTex;
			float _RimPower;
			float _OffSet;
			fixed4 _EdgeColor;
			fixed4 _RimColor;
			float _Edge, _Brightness;
			float _Scale;
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(viewNormal.xy);
				o.pos.xy += offset * _OutlineScale * o.pos.z ;
				o.pos.z += _OutlineZ;
				o.viewDir = normalize(WorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
				o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
				return o;
			}
			
			float4 frag(v2f i): SV_Target
			{
				float2 uv = float2(i.pos.x * _Scale - _Time.x * _XSpeed, i.pos.y * _Scale - _Time.x * _YSpeed);
				float4 noise = tex2D(_NoiseTex, uv);
				//使用Rim 可以实现边缘淡化效果
				float4 rim = pow(saturate(dot(i.viewDir, i.normalDir)), _RimPower);
				rim -= noise;
				
				float4 edgeRim = saturate(rim.a + _OffSet);
				//挤出外描边
				float4 extraRim = (saturate((_Edge + rim.a) * _OffSet) - edgeRim) * _Brightness ;
				float4 result = (edgeRim * _EdgeColor) + (extraRim * _RimColor);
				return result;
			}
			ENDCG
			
		}
	}
}
