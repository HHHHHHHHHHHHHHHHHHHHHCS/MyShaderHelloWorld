using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Lighting2D
{
	[ExecuteInEditMode]
	[ImageEffectAllowedInSceneView]
	[RequireComponent(typeof(Camera))]
	public class Light2DRenderer : MonoBehaviour
	{
		private Camera cam;

		private void Awake()
		{
			cam = GetComponent<Camera>();
		}

		private void OnPreRender()
		{
			var profile = LightSystem.Instance.SetupCamera(cam);
			LightSystem.Instance.RenderDeffer(profile);
		}
	}
}