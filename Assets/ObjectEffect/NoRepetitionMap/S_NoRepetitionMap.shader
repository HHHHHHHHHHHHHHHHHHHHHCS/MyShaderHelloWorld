Shader "ObjectEffect/S_NoRepetitionMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BlendScale ("BlendScale", Range(0, 0.5)) = 0.25
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _BlendScale;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float4 Hash4(float2 p)
			{
				return frac(sin(float4(
					1.0 + dot(p, float2(37.0, 17.0)),
					2.0 + dot(p, float2(11.0, 47.0)),
					3.0 + dot(p, float2(41.0, 29.0)),
					4.0 + dot(p, float2(23.0, 31.0))
				)) * 103.0);
			}
			
			float4 TextureNoTile(sampler2D samp, float2 uv)
			{
				//当前位置
				float2 iuv = floor(uv);
				//当前的UV
				float2 fuv = frac(uv);
				
				//4个随机因子 ， xy位移 ， zw翻转
				float4 ofa = Hash4(iuv + float2(0.0, 0.0));
				float4 ofb = Hash4(iuv + float2(1.0, 0.0));
				float4 ofc = Hash4(iuv + float2(0.0, 1.0));
				float4 ofd = Hash4(iuv + float2(1.0, 1.0));
				
				float2 dx = ddx(uv);
				float2 dy = ddy(uv);
				
				//zw的范围是[0,1]，-0.5，得到符号
				ofa.zw = sign(ofa.zw - 0.5);
				ofb.zw = sign(ofb.zw - 0.5);
				ofc.zw = sign(ofc.zw - 0.5);
				ofd.zw = sign(ofd.zw - 0.5);
				
				float2 uva = uv * ofa.zw + ofa.xy;
				float2 ddxa = dx * ofa.zw;
				float2 ddya = dy * ofa.zw;
				float2 uvb = uv * ofb.zw + ofb.xy;
				float2 ddxb = dx * ofb.zw;
				float2 ddyb = dy * ofb.zw;
				float2 uvc = uv * ofc.zw + ofc.xy;
				float2 ddxc = dx * ofc.zw;
				float2 ddyc = dy * ofc.zw;
				float2 uvd = uv * ofd.zw + ofd.xy;
				float2 ddxd = dx * ofd.zw;
				float2 ddyd = dy * ofd.zw;
				
				float2 b = smoothstep(_BlendScale, 1 - _BlendScale, fuv);
				//先通过 fuv的x分量 将 ↙↘和↖↗分别融合，再通过y分量将上下两部分融合。
				//tex2D(sampler2D tex , float2 s , float2 dsdx , float2 dsdy ) 二维非射影纹理查询与导数
				return lerp(lerp(tex2D(samp, uva, ddxa, ddya),
				tex2D(samp, uvb, ddxb, ddyb), b.x),
				lerp(tex2D(samp, uvc, ddxc, ddyc),
				tex2D(samp, uvd, ddxd, ddyd), b.x), b.y);
			}
			
			float4 frag(v2f i): SV_Target
			{
				float4 col = TextureNoTile(_MainTex, i.uv);
				return col;
			}
			ENDCG
			
		}
	}
}
