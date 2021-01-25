Shader "ObjectEffect/S_ShadowVolumeDepthFail"
{
	Properties { }
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+1" }
		LOD 100
		
		CGINCLUDE
		
		#include "UnityCG.cginc"
		struct a2v
		{
			float4 vertex: POSITION;
		};
		
		struct v2f
		{
			float4 vertex: SV_POSITION;
		};
		
		v2f vert(a2v v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			return o;
		}
		
		half4 frag(v2f i): SV_TARGET
		{
			return half4(0.3, 0.3, 0.3, 1);
		}
		
		ENDCG
		
		Pass
		{
			Cull Front          //阴影体内侧像素Z测试失败，stencil值加1
			Stencil
			{
				Ref 0           //0-255
				Comp always     //default:always
				Pass keep       //default:keep
				Fail keep       //default:keep
				ZFail IncrWrap  //default:keep
			}
			
			ColorMask 0         //关闭color buffer写入
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
			
		}
		
		Pass
		{
			//阴影体外侧像素Z测试失败，stencil值减1
			Cull Back
			Stencil
			{
				Ref 0
				Comp Always
				Pass Keep
				Fail Keep
				ZFail DecrWrap
			}
			ColorMask 0
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
			
		}
		
		Pass
		{
			Cull Back          //经过前两个pass，stencil值为1的值为在此阴影体内被阴影覆盖的像素
			Stencil
			{
				Ref 1          //0-255
				Comp equal     //default:always
				Pass keep   //default:keep
				Fail keep      //default:keep
				ZFail keep  //default:keep
			}
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
			
		}
	}
}
