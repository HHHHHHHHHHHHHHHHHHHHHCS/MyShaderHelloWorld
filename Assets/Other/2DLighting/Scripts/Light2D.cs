using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	public class Light2D : MonoBehaviour
	{
		public LightShadows lightShadows;


		public void RenderShadow(CommandBuffer cmd, int shadowMapID)
		{
		}

		public void RenderLight(CommandBuffer cmd)
		{
		}
	}
}