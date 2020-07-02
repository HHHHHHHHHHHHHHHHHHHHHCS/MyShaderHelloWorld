using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	[RequireComponent(typeof(SpriteRenderer))]
	public class SpriteLight : Light2DBase
	{
		public float intensity = 1;

		public override void RenderLight(CommandBuffer cmd)
		{
			var renderer = GetComponent<SpriteRenderer>();
			renderer.sharedMaterial.color *= intensity;
			cmd.DrawRenderer(renderer,renderer.material);
			renderer.sharedMaterial.color = renderer.color;
		}
	}
}

