using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	public enum ShadowSmooth
	{
		Blur,
		DownSample,
		VolumnLight,
	}

	public abstract class Light2DBase : MonoBehaviour
	{
		public LightShadows lightShadows = LightShadows.None;
		public ShadowSmooth shadowSmooth = ShadowSmooth.Blur;

		[Range(1, 64)] public int smoothRadius;
		public float lightVolume = 1;
		public float lightDistance = 20;

		public abstract void RenderLight(CommandBuffer cmd);

		[SerializeField] private bool debugLight;

		[SerializeField] private bool debugShadow;

		protected Material shadowMat;

		private Collider2D[] shadowCasters = new Collider2D[100];

		private Mesh shadowMesh;

		private Mesh tempMesh;

		private void Reset()
		{
			if (tempMesh)
			{
				tempMesh.Clear();
			}
			else
			{
				tempMesh = new Mesh();
				tempMesh.name = "Sub Shadow Mesh";
			}

			if (shadowMesh)
			{
				shadowMesh.Clear();
			}
			else
			{
				shadowMesh = new Mesh();
				shadowMesh.name = "Shadow Mesh";
			}

			if (shadowMat)
			{
				GameObject.DestroyImmediate(shadowMat);
			}

			shadowMat = new Material(Shader.Find("Lighting2D/Shadow"));
		}

		protected virtual void Start()
		{
			Reset();
		}
	}
}