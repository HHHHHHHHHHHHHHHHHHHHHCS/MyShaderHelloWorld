using System;
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

		public Mesh PolygonShadowMesh(PolygonCollider2D pol)
		{
			var points = pol.GetPath(0);
			var z = new Vector3(0, 0, 1);
			MeshBuilder meshBuilder = new MeshBuilder(5 * points.Length, 3 * points.Length);
			var R_2 = Mathf.Pow(lightDistance, 2);
			var r_2 = Mathf.Pow(lightVolume, 2);

			for (var i = 0; i < points.Length; i++)
			{
				// transform points from collider space to light space
				Vector3 p0 =
					transform.worldToLocalMatrix.MultiplyPoint(
						pol.transform.localToWorldMatrix.MultiplyPoint(points[(i + 1) % points.Length]));
				Vector3 p1 =
					transform.worldToLocalMatrix.MultiplyPoint(
						pol.transform.localToWorldMatrix.MultiplyPoint(points[i]));

				p0.z = p1.z = 0;

				var ang0 = Mathf.Asin(lightVolume / p0.magnitude); //angle between lightDir & tangent of light circle
				var ang1 = Mathf.Asin(lightVolume / p1.magnitude); //angle between lightDir & tangent of light circle

				Vector3 shadowA = MathUtility.Rotate(p0, -ang0).normalized *
				                  (Mathf.Sqrt(R_2 - r_2) - p0.magnitude * Mathf.Cos(ang0));
				Vector3 shadowB = MathUtility.Rotate(p1, ang1).normalized *
				                  (Mathf.Sqrt(R_2 - r_2) - p1.magnitude * Mathf.Cos(ang1));

				shadowA += p0;
				shadowB += p1;
				//TODO:
			}

			throw new Exception();
		}
	}
}