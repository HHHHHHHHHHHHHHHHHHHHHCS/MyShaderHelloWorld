using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using Object = System.Object;

namespace Lighting2D
{
	//[ExecuteInEditMode]
	public class LightSystem : Singleton<LightSystem>
	{
		public int lightMapResolutionScale = 1;
		public int shadowMapResolutionScale = 1;
		public FilterMode shadowMapFilterMode = FilterMode.Bilinear;

		public Material gaussianMat;
		public Material lightingMaterial = null;

		public bool previewInInspector = true;
		public float exposureLimit = -1;

		private Dictionary<Camera, Light2DProfile> cameraProfiles;

		private void Awake()
		{
			
			cameraProfiles = new Dictionary<Camera, Light2DProfile>();

			if (!lightingMaterial)
			{
				lightingMaterial = new Material(Shader.Find("Lighting2D/DeferredLighting"));
				lightingMaterial.hideFlags = HideFlags.HideAndDontSave;
			}

			if (!gaussianMat)
			{
				gaussianMat = new Material(Shader.Find("Lighting2D/Gaussian"));
				gaussianMat.hideFlags = HideFlags.HideAndDontSave;
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
				_camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, profile.commandBuffer);
			}

			return cameraProfiles[_camera];
		}

		public void RenderDeffer(Light2DProfile profile)
		{
			var camera = profile.camera;
			var cmd = profile.commandBuffer;
			cmd.Clear();

			cmd.BeginSample("2D Lighting");

			//注意:UNITY 没有处理BLIT 可能存在图片颠倒的情况
			var useMSAA = profile.camera.allowMSAA && QualitySettings.antiAliasing > 0 ? 1 : 0;
			cmd.SetGlobalInt("_UseMSAA", useMSAA);
#if UNITY_EDITOR
			if (UnityEditor.SceneView.GetAllSceneCameras().Any(cam => cam == camera))
			{
				if (!previewInInspector)
					return;
				cmd.SetGlobalInt("_SceneView", 1);
			}
			else
			{
				cmd.SetGlobalInt("_SceneView", 0);
			}
#endif

			var diffuse = Shader.PropertyToID("_Diffuse");
			cmd.GetTemporaryRT(diffuse, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.Default,
				RenderTextureReadWrite.Default, 1);
			cmd.Blit(BuiltinRenderTextureType.CameraTarget, diffuse);

			var shadowMap = Shader.PropertyToID("_ShadowMap");
			cmd.GetTemporaryRT(shadowMap, camera.pixelWidth / shadowMapResolutionScale,
				camera.pixelHeight / shadowMapResolutionScale, 0, shadowMapFilterMode);

			var lightMap = profile.lightMap;
			cmd.SetRenderTarget(lightMap, lightMap);
			cmd.ClearRenderTarget(true, true, Color.black);

			bool renderedShadow = false;
			var lights = GameObject.FindObjectsOfType<Light2D>();
			foreach (var light in lights)
			{
				if(renderedShadow)
				{
					cmd.SetRenderTarget(shadowMap);
					cmd.ClearRenderTarget(true, true, Color.black);
				}
				
				if (light.lightShadows != LightShadows.None)
				{
					cmd.SetRenderTarget(shadowMap);
					light.RenderShadow(cmd, shadowMap);
					renderedShadow = true;
				}
				else
				{
					renderedShadow = false;
				}

				if (renderedShadow)
				{
					cmd.SetRenderTarget(lightMap, lightMap);
				}

				light.RenderLight(cmd);
			}

			cmd.SetGlobalFloat("_ExposureLimit", exposureLimit);
			cmd.SetGlobalTexture("_LightMap", lightMap);
			cmd.Blit(diffuse, BuiltinRenderTextureType.CameraTarget, lightingMaterial, 0);

			cmd.ReleaseTemporaryRT(shadowMap);
			cmd.ReleaseTemporaryRT(diffuse);
			cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget);
			cmd.EndSample("2D Lighting");
		}
	}
}