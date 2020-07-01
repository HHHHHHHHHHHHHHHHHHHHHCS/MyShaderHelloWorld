using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	public class GaussianBlur : MonoBehaviour
	{
		public static void Blur(int radius, CommandBuffer cmd, RenderTargetIdentifier src, RenderTargetIdentifier dest,
			Material mat)
		{
			var blurTexture = Shader.PropertyToID("__GaussianBlurTexture");
			cmd.SetGlobalInt("_BlurRadius", radius);
			cmd.GetTemporaryRT(blurTexture, -1, -1);
			cmd.SetGlobalVector("_BlurDirection", new Vector4(1, 0));
			cmd.Blit(src, blurTexture, mat);
			cmd.SetGlobalVector("_BlurDirection", new Vector4(0, 1));
			cmd.Blit(blurTexture, dest, mat);
			cmd.ReleaseTemporaryRT(blurTexture);
		}
	}
}