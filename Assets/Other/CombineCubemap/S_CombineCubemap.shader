Shader "Other/S_CombineCubemap"
{
	Properties
	{
		_LeftImage ("_LeftImage", 2D) = "white" { }
		_RightImage ("_RightImage", 2D) = "white" { }
		_BottomImage ("_BottomImage", 2D) = "white" { }
		_TopImage ("_TopImage", 2D) = "white" { }
		_BackImage ("_BackImage", 2D) = "white" { }
		_FrontImage ("_FrontImage", 2D) = "white" { }
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
			
			sampler2D _LeftImage;
			sampler2D _RightImage;
			sampler2D _BottomImage;
			sampler2D _TopImage;
			sampler2D _BackImage;
			sampler2D _FrontImage;
			
			
			v2f vert(appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * 2 - 1;
				return o;
			}
			
			fixed4 frag(v2f i): SV_Target
			{
				float theta = i.uv.x * UNITY_PI ;
				float phi = (i.uv.y * UNITY_PI) / 2;
				
				float x = cos(phi) * sin(theta);
				float y = sin(phi);
				float z = cos(phi) * cos(theta);
				
				float scale;
				float2 px;
				float4 src;
				
				if (abs(x) >= abs(y) && abs(x) >= abs(z))
				{
					if(x < 0.0)
					{
						scale = -1.0 / x;
						px.x = (z * scale + 1.0) / 2.0;
						px.y = (y * scale + 1.0) / 2.0;
						src = tex2D(_RightImage, px);
					}
					else
					{
						scale = 1.0 / x;
						px.x = (-z * scale + 1.0) / 2.0;
						px.y = (y * scale + 1.0) / 2.0;
						src = tex2D(_LeftImage, px);
					}
				}
				else if(abs(y) >= abs(z))
				{
					if(y < 0.0)
					{
						scale = -1.0 / y;
						px.x = (x * scale + 1.0) / 2.0;
						px.y = (z * scale + 1.0) / 2.0;
						src = tex2D(_BottomImage, px);
					}
					else
					{
						scale = 1.0 / y;
						px.x = (x * scale + 1.0) / 2.0;
						px.y = (-z * scale + 1.0) / 2.0;
						src = tex2D(_TopImage, px);
					}
				}
				else
				{
					if(z < 0.0)
					{
						scale = -1.0 / z;
						px.x = (-x * scale + 1.0) / 2.0;
						px.y = (y * scale + 1.0) / 2.0;
						src = tex2D(_BackImage, px);
					}
					else
					{
						scale = 1.0 / z;
						px.x = (x * scale + 1.0) / 2.0;
						px.y = (y * scale + 1.0) / 2.0;
						src = tex2D(_FrontImage, px);
					}
				}
				
				return src;
			}
			ENDCG
			
		}
	}
}
