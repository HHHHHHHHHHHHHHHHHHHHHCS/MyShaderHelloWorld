Shader "CommandBufferSamples/S_BlurGlass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
	}
	
	CGINCLUDE
	
	
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
	float4 _MainTex_TexelSize;
	
	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}
	
	
	float4 Downsample(float2 uv)
	{
		float2 UV;
		float4 sum;
		
		float twoPixelX = _MainTex_TexelSize.x * 2;
		float twoPixelY = _MainTex_TexelSize.y * 2;
		
		sum = tex2D(_MainTex, uv) * 4.0;
		
		UV = float2(uv.x - twoPixelX, uv.y - twoPixelY);
		sum += tex2D(_MainTex, UV) ;
		
		UV = float2(uv.x + twoPixelX, uv.y + twoPixelY);
		sum += tex2D(_MainTex, UV) ;
		
		UV = float2(uv.x + twoPixelX, uv.y - twoPixelY);
		sum += tex2D(_MainTex, UV) ;
		
		UV = float2(uv.x - twoPixelX, uv.y + twoPixelY);
		sum += tex2D(_MainTex, UV) ;
		
		return sum * 0.125;
	}
	
	float4 Upsample(float2 uv)
	{
		float2 UV;
		float4 sum;
		float halfPixelX = _MainTex_TexelSize.x * 0.5;
		float halfPixelY = _MainTex_TexelSize.y * 0.5;
		
		UV = float2(uv.x - halfPixelX * 2.0, uv.y);
		sum = tex2D(_MainTex, UV);
		
		UV = float2(uv.x - halfPixelX, uv.y + halfPixelY);
		sum += tex2D(_MainTex, UV) * 2.0;
		
		UV = float2(uv.x, uv.y + halfPixelY * 2.0);
		sum += tex2D(_MainTex, UV);
		
		UV = float2(uv.x + halfPixelX, uv.y + halfPixelY);
		sum += tex2D(_MainTex, UV) * 2.0;
		
		UV = float2(uv.x + halfPixelX * 2.0, uv.y);
		sum += tex2D(_MainTex, UV);
		
		UV = float2(uv.x + halfPixelX, uv.y - halfPixelY);
		sum += tex2D(_MainTex, UV) * 2.0;
		
		UV = float2(uv.x, uv.y - halfPixelY * 2.0);
		sum += tex2D(_MainTex, UV);
		
		UV = float2(uv.x - halfPixelX, uv.y - halfPixelY);
		sum += tex2D(_MainTex, UV) * 2.0;
		
		return sum / 12.0;
	}
	
	float4 GaussianBlur(float2 uv)
	{
		float2 UV;
		float4 col;
		float pixelX = _MainTex_TexelSize.x * 2.0;
		float pixelY = _MainTex_TexelSize.y * 2.0;
		
		UV = float2(uv.x, uv.y);
		col = tex2D(_MainTex, UV) * 0.147761;
		
		UV = float2(uv.x, uv.y + pixelY);
		col += tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x, uv.y - pixelY);
		col += tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x + pixelX, uv.y);
		col += tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x - pixelX, uv.y);
		col += tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x + pixelX, uv.y + pixelY);
		col += tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x - pixelX, uv.y - pixelY);
		col += tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x + pixelX, uv.y - pixelY);
		col += tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x - pixelX, uv.y + pixelY);
		col += tex2D(_MainTex, UV) * 0.0947416;
		
		return col;
	}
	
	float4 GaussianClear(float2 uv)
	{
		float2 UV;
		float4 col;
		float pixelX = _MainTex_TexelSize.x * 2.0;
		float pixelY = _MainTex_TexelSize.y * 2.0;
		
		UV = float2(uv.x, uv.y);
		col = tex2D(_MainTex, UV);
		
		UV = float2(uv.x, uv.y + pixelY);
		col -= tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x, uv.y - pixelY);
		col -= tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x + pixelX, uv.y);
		col -= tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x - pixelX, uv.y);
		col -= tex2D(_MainTex, UV) * 0.118318;
		
		UV = float2(uv.x + pixelX, uv.y + pixelY);
		col -= tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x - pixelX, uv.y - pixelY);
		col -= tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x + pixelX, uv.y - pixelY);
		col -= tex2D(_MainTex, UV) * 0.0947416;
		
		UV = float2(uv.x - pixelX, uv.y + pixelY);
		col -= tex2D(_MainTex, UV) * 0.0947416;
		
		col = saturate(col);
		
		return col / 0.147761;
	}
	
	ENDCG
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		
		//0.Downsample
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			float4 frag(v2f i): SV_Target
			{
				return Downsample(i.uv);
			}
			
			ENDCG
			
		}
		
		//1.Upsample
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			float4 frag(v2f i): SV_Target
			{
				return Upsample(i.uv);
			}
			
			ENDCG
			
		}
		
		//2.GaussianBlur
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			float4 frag(v2f i): SV_Target
			{
				return GaussianBlur(i.uv);
			}
			
			ENDCG
			
		}
		
		//3.GaussianClear
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			float4 frag(v2f i): SV_Target
			{
				return GaussianClear(i.uv);
			}
			
			ENDCG
			
		}
	}
}
