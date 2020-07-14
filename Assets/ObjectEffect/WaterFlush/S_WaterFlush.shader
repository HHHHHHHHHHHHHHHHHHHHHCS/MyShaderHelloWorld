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
		
		_Votex_Para ("Center", vector) = (0.5, 0.5, 0.2, 0)  //x,y:漩涡中心  z:漩涡半径
		_Votex_depth ("Votex Depth", Range(0, 4)) = 0.1    //漩涡深度
		_Votex_distortAmount ("Votex_distortAmount", Range(0, 20)) = 2 //扭曲力度
		
		_Shape_distortAmount ("Shape_distortAmount", Range(0, 1)) = 0.5//漩涡塑形
	}
	
	CGINCLUDE
	
	sampler2D _NormalTex, _FoamTex;
	half4 _NormalTex_ST, _FoamTex_ST;
	float _XSpeed, _YSpeed, _Gloss, _SpecStrengh, _TessellateAmount, _FoamStrengh;
	half4 _BaseColor, _Votex_Para, _Votex_Para1;
	float _Votex_distortAmount, _Shape_distortAmount, _RefractionAmount;
	sampler2D _GrabTex;
	float4 _GrabTex_TexelSize;
	
	struct v2f
	{
		float4 uv: TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex: SV_POSITION;
		float3 normal: NORMAL;
		float4 screenPos: TEXCOORD2;
		float4 localPosition: TEXCOORD3;
	};
	
	v2f vert(appdata_base v)
	{
		v2f o;
		
		
		
		return o;
	}
	
	half4 frag(v2f i): SV_Target
	{
		
		return 0;
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
	[UNITY_patchconstantfunc("hsconst_surf")]//计算factor的方法
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
			#pragma multi_compile_fog
			#pragma nodynlightmap nolightmap//禁用动态光照贴图
			
			#include "UnityCG.cginc"
			
			ENDCG
			
		}
	}
}