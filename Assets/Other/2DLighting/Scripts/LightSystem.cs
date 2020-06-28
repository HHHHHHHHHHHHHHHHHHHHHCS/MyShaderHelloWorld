using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	//[ExecuteInEditMode]
	[RequireComponent(typeof(MeshRenderer))]
	public class LightSystem : Singleton<LightSystem>
	{
		public const int lightMapResolutionScale = 1;
		public const int shadowMapResolutionScale = 1;
		public const FilterMode shadowMapFilterMode = FilterMode.Bilinear;

		public Material lightingMaterial;

		private Dictionary<Camera, Light2DProfile> cameraProfiles;

		private void Awake()
		{
			cameraProfiles = new Dictionary<Camera, Light2DProfile>();
			if (!lightingMaterial)
			{
				lightingMaterial = new Material(Shader.Find("Lighting2D/DeferredLighting"));
			}
		}

		[Lighting2D.Editor.EditorButton("Reset")]
		public void Reset()
		{
			cameraProfiles.Clear();
		}

		public Light2DProfile SetupCamera(Camera _camera)
		{
			if (!cameraProfiles.ContainsKey(_camera))
			{
				_camera.RemoveAllCommandBuffers();
				var profile = new Light2DProfile()
				{
					camera = _camera,
					commandBuffer = new CommandBuffer(),
					lightMap = new RenderTexture(_camera.pixelWidth / lightMapResolutionScale,
						_camera.pixelHeight / lightMapResolutionScale, 0, RenderTextureFormat.ARGBFloat)
				};
				profile.lightMap.filterMode = FilterMode.Point;
				profile.lightMap.antiAliasing = 1;
				cameraProfiles[_camera] = profile;
				profile.commandBuffer.name = "2D Lighting";
				profile.lightMap.name = "Light Map";
				_camera.AddCommandBuffer(CameraEvent.BeforeImageEffects,profile.commandBuffer);
			}

			return cameraProfiles[_camera];
		}
	}
}