Shader "WaterFlush/S_WaterFlush"
{
	Properties
	{
		_BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
		[Normal]_NormalTex ("Normal", 2D) = "white" { }
		_FoamTex ("FoamTex", 2D) = "white" { }
		_FoamStrengh ("FoamStrengh", Range(0, 1)) = 0.2
		_XSpeed ("XSpeed", Range(0, 1)) = 0.2
		_YSpeed ("YSpeed", Range(0, 1)) = 0.2
		_Gloss ("Gloss", Range(0, 0.1)) = 0.1
		_SpecStrengh ("SpecStrengh", Range(0, 0.01)) = 1
		_RefractionAmount ("RefractAmount", Range(0, 100)) = 5
		_TessellateAmount ("TessellateAmount", float) = 4
		
		_Votex_Para ("Votex Par", vector) = (0.5, 0.5, 0.2, 0)  //x,y:漩涡中心  z:漩涡半径
		_Votex_Para1 ("Votex Para1", vector) = (0.5, 0.5, 3, 0)//x,y:漩涡底部  z:漩涡深度
		_Votex_distortAmount ("Votex_distortAmount", Range(0, 20)) = 2 //扭曲力度
		
		_Shape_distortAmount ("Shape_distortAmount", Range(0, 1)) = 0.5//漩涡塑形
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	#include "AutoLight.cginc"
	#include "Lighting.cginc"
	
	struct v2f
	{
		float4 uv: TEXCOORD0;
		float4 vertex: SV_POSITION;
		float3 normal: NORMAL;
		float4 screenPos: TEXCOORD1;
		float4 localPosition: TEXCOORD2;
	};
	
	sampler2D _NormalTex, _FoamTex;
	half4 _NormalTex_ST, _FoamTex_ST;
	float _XSpeed, _YSpeed, _Gloss, _SpecStrengh, _TessellateAmount, _FoamStrengh;
	half4 _BaseColor, _Votex_Para, _Votex_Para1;
	float _Votex_distortAmount, _Shape_distortAmount, _RefractionAmount;
	sampler2D _GrabTex;
	float4 _GrabTex_TexelSize;
	
	//绕某条轴旋转特定角度(弧度)
	float3x3 AngleAxis3x3(float angle, float3 axis)
	{
		float c, s;
		sincos(angle, s, c);
		
		float t = 1 - c;
		float x = axis.x;
		float y = axis.y;
		float z = axis.z;
		
		return float3x3(
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c
		);
	}
	
	
	half3 BlendNormalRNM(half3 n1, half3 n2)
	{
		half3 t = n1.xyz + half3(0.0, 0.0, 1.0);
		half3 u = n2.xyz * half3(-1.0, -1.0, 1.0);
		half3 r = (t / t.z) * dot(t, u) - u;
		return r;
	}
	
	
	//specular
	half3 Highlights(half3 positionWS, half roughness, half3 normalWS, half3 viewDirectionWS, half3 lightDir)
	{
		
		half roughness2 = roughness * roughness;
		half3 halfDir = normalize(lightDir + viewDirectionWS);
		half NoH = saturate(dot(normalize(normalWS), halfDir));
		half LoH = saturate(dot(lightDir, halfDir));
		// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
		// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
		// https://community.arm.com/events/1155
		half d = NoH * NoH * (roughness2 - 1.h) + 1.0001h;
		half LoH2 = LoH * LoH;
		half specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * (roughness + 0.5h) * 4);
		// on mobiles (where half actually means something) denominator have risk of overflow
		// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
		// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
		#if defined(SHADER_API_MOBILE)
			// specularTerm = specularTerm - HALF_MIN;
			specularTerm = clamp(specularTerm, 0.0, 5.0); // Prevent FP16 overflow on mobiles
		#endif
		return specularTerm * _LightColor0;
	}
	
	v2f vert(appdata_base v)
	{
		v2f o;
		
		float3 center = float3(_Votex_Para.x, 0, _Votex_Para.y);
		float3 bottomCenter = _Votex_Para1.xzy;
		float3 mainVec = bottomCenter - center;
		float radius = _Votex_Para.z;
		float dis = distance(v.vertex.xyz, center);
		float s = saturate((radius - dis)) / radius;
		float ss = s * s;
		//越靠近漩涡中心 ,  顶点偏移量越大 . ss = s * s 能够产生漩涡的弧形
		float offsetN = _Votex_Para1.z * ss;
		
		//进行顶点的偏移
		v.vertex.xyz = v.vertex.xyz - v.normal * offsetN;
		v.vertex.xyz = lerp(v.vertex.xyz, bottomCenter, offsetN / _Votex_Para1.z);
		
		//绕任意轴旋转矩阵
		float3 mainDir = normalize(mainVec);
		float3x3 matrix_MainVec = AngleAxis3x3(abs(v.vertex.y * _Votex_distortAmount), mainDir);
		
		//扭曲(绕mainDir轴旋转)
		//v.vertex.xyz = mul(marix_MainVec, v.vertex);
		
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _NormalTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _FoamTex);
		o.localPosition = v.vertex;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.normal = v.normal;
		o.screenPos = ComputeGrabScreenPos(o.vertex);
		
		return o;
	}
	
	half4 frag(v2f i): SV_Target
	{
		half4 mainColor = _BaseColor;
		float4 worldPosition = mul(unity_ObjectToWorld, i.localPosition);
		
		float3 n1 = UnpackNormal(tex2D(_NormalTex, i.uv.xy + float2(_XSpeed, _YSpeed) * 0.1 * _Time.y));
		float3 n2 = UnpackNormal(tex2D(_NormalTex, i.uv.xy - float2(_XSpeed, _YSpeed) * 0.1 * _Time.y));
		float3 offset = BlendNormalRNM(n1, n2);
		
		//泡沫
		float4 foamColor = tex2D(_FoamTex, i.uv.zw);
		mainColor += foamColor * _FoamStrengh;
		
		//透明
		i.screenPos.xy /= i.screenPos.w;
		//折射(漩涡处折射加大)
		i.screenPos.xy += offset.xy * (_RefractionAmount + abs(i.localPosition.y) * 400) * _GrabTex_TexelSize.xy;
		float4 backColor = tex2D(_GrabTex, i.screenPos.xy);
		mainColor *= backColor;
		
		//光照(高光部分没有法线)
		half3 worldViewDir = normalize(WorldSpaceViewDir(worldPosition));
		half3 worldLightDir = normalize(WorldSpaceLightDir(worldPosition));
		half3 objectWorldNormal = UnityObjectToWorldNormal(i.normal);
		half3 specular = Highlights(worldPosition.xyz, _Gloss, normalize(objectWorldNormal - offset), worldViewDir, worldLightDir);
		mainColor.rgb += specular * _SpecStrengh * (0.05 + abs(i.localPosition.y) * 400);
		
		return mainColor;
	
	}
	
	
	
	//曲面细分
	// tessellation vertex shader
	struct InternalTessInterp_appdata_base
	{
		float4 vertex: INTERNALTESSPOS;
		float3 normal: NORMAL;
		float4 texcoord: TEXCOORD0;
	};
	
	InternalTessInterp_appdata_base tessvert_surf(appdata_base v)
	{
		InternalTessInterp_appdata_base o;
		o.vertex = v.vertex;
		o.normal = v.normal;
		o.texcoord = v.texcoord;
		return o;
	}
	
	// 计算每个边的Tessellation factor和内部的Inside Tessellation factor
	UnityTessellationFactors hsconst_surf(InputPatch < InternalTessInterp_appdata_base, 3 > v)
	{
		UnityTessellationFactors o;
		float4 tf;
		tf = _TessellateAmount;
		o.edge[0] = tf.x;
		o.edge[1] = tf.y;
		o.edge[2] = tf.z;
		o.inside = tf.w;
		return o;
	}
	
	[UNITY_domain("tri")]
	[UNITY_partitioning("fractional_odd")]//决定舍入规则，fractional_odd意为factor截断在[1,max]范围内，然后取整到小于此数的最大奇数整数值
	[UNITY_outputtopology("triangle_cw")]//决定图元的朝向，由组成三角形的三个顶点的顺序所产生的方向决定，cw为clockwise顺时针，ccw为counter clockwise逆时针。
	[UNITY_patchconstantfunc("hsconst_surf")]//计算细分值的方法 hsconst_surf 是固定值
	[UNITY_outputcontrolpoints(3)]
	InternalTessInterp_appdata_base hs_surf(InputPatch < InternalTessInterp_appdata_base, 3 > v, uint id: SV_OutputControlPointID)
	{
		return v[id];
	}
	
	/*
	SV_DomainLocation
	Type	Input Topology
	float2	quad patch		    //xy坐标
	float3	tri patch			//重心坐标
	float2	isoline				//xy坐标
	*/
	[UNITY_domain("tri")]
	v2f ds_surf(UnityTessellationFactors tessFactors, const OutputPatch < InternalTessInterp_appdata_base, 3 > vi, float3 bary: SV_DomainLocation)
	{
		appdata_base v;
		UNITY_INITIALIZE_OUTPUT(appdata_base, v);
		v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
		v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
		v.texcoord = vi[0].texcoord * bary.x + vi[1].texcoord * bary.y + vi[2].texcoord * bary.z;
		v2f o = vert(v);
		return o;
	}
	
	ENDCG
	
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass
		{
			"_GrabTex"
		}
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex tessvert_surf
			#pragma fragment frag
			#pragma hull hs_surf
			#pragma domain ds_surf
			#pragma target 5.0
			#pragma nodynlightmap nolightmap//禁用动态光照贴图
			
			
			ENDCG
			
		}
	}
}