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


		[SerializeField] private bool debugLight;

		[SerializeField] private bool debugShadow;

		protected Material shadowMat;

		private Collider2D[] shadowCasters = new Collider2D[100];

		private Mesh shadowMesh;

		private Mesh tempMesh;

		protected string shadowShaderName { get; } = "Lighting2D/Shadow2D";

		public abstract void RenderLight(CommandBuffer cmd);

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

			var shader = Shader.Find(shadowShaderName);
			if (shadowMat && shadowMat.shader != shader)
			{
				GameObject.DestroyImmediate(shadowMat);
				shadowMat = null;
				shadowMat = new Material(shader);
			}

			if (shadowMat == null)
			{
				shadowMat = new Material(shader);
			}
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

				int meshType = 0;
				if (Vector3.Cross(p1 - p0, shadowB - p1).z >= 0)
				{
					meshType |= 1;
					shadowB = MathUtility.Rotate(p0, ang0).normalized *
					          (Mathf.Sqrt(R_2 - r_2) - p1.magnitude * Mathf.Cos(ang1));
					shadowB += p0;
				}

				if (Vector3.Cross(p0 - shadowA, p1 - p0).z >= 0)
				{
					meshType |= 2;
					shadowA = MathUtility.Rotate(p1, -ang1).normalized *
					          (Mathf.Sqrt(R_2 - r_2) - p1.magnitude * Mathf.Cos(ang1));
					shadowA += p1;
				}

				var oc = (shadowA + shadowB) / 2;
				Vector3 shadowR = oc.normalized * (R_2 / oc.magnitude);
				Vector3 normal = Vector3.Cross(z, p1 - p0);


				if (meshType == 0)
				{
					meshBuilder.AddVertsAndTriangles(new Vector3[]
					{
						p0,
						p1,
						shadowB,
						shadowA,
						shadowR,
					}, new int[]
					{
						0, 3, 4,
						1, 0, 4,
						1, 4, 2,
					}, new Vector2[]
					{
						p0,
						p0,
						p0,
						p0,
						p0,
					}, new Vector2[]
					{
						p1,
						p1,
						p1,
						p1,
						p1,
					});
				}
				else if (meshType == 1) // merge p0->p1 & p1->shadowB
				{
					meshBuilder.AddVertsAndTriangles(new Vector3[]
					{
						p0,
						shadowB,
						shadowA,
						shadowR,
					}, new int[]
					{
						0, 2, 3,
						0, 3, 1
					}, new Vector2[]
					{
						p0,
						p0,
						p0,
						p0,
					}, new Vector2[]
					{
						p1,
						p1,
						p1,
						p1,
					});
				}
				else if (meshType == 2) // merge shadowA->p0 & p0->p1
				{
					meshBuilder.AddVertsAndTriangles(new Vector3[]
					{
						p1,
						shadowB,
						shadowA,
						shadowR,
					}, new int[]
					{
						0, 2, 3,
						0, 3, 1
					}, new Vector2[]
					{
						p0,
						p0,
						p0,
						p0,
					}, new Vector2[]
					{
						p1,
						p1,
						p1,
						p1,
					});
				}
				else if (meshType == 3) // cross
				{
					meshBuilder.AddVertsAndTriangles(new Vector3[]
					{
						p1,
						p0,
						shadowB,
						shadowA,
						shadowR,
					}, new int[]
					{
						0, 3, 4,
						1, 0, 4,
						1, 4, 2,
					}, new Vector2[]
					{
						p1,
						p1,
						p1,
						p1,
						p1,
					}, new Vector2[]
					{
						p0,
						p0,
						p0,
						p0,
						p0,
					});
				}

				if (debugShadow)
				{
					Debug.DrawLine(transform.localToWorldMatrix.MultiplyPoint(p0),
						transform.localToWorldMatrix.MultiplyPoint(p1), Color.red);
					Debug.DrawLine(transform.localToWorldMatrix.MultiplyPoint(p1),
						transform.localToWorldMatrix.MultiplyPoint(shadowB), Color.green);
					Debug.DrawLine(transform.localToWorldMatrix.MultiplyPoint(p0),
						transform.localToWorldMatrix.MultiplyPoint(shadowA), Color.blue);
					Debug.DrawLine(transform.localToWorldMatrix.MultiplyPoint(shadowA),
						transform.localToWorldMatrix.MultiplyPoint(shadowR), Color.white);
					Debug.DrawLine(transform.localToWorldMatrix.MultiplyPoint(shadowB),
						transform.localToWorldMatrix.MultiplyPoint(shadowR), Color.white);
					return meshBuilder.ToMesh(shadowMesh);
				}
			}

			var mesh = meshBuilder.ToMesh(tempMesh);
			mesh.RecalculateNormals();
			return mesh;
		}

		public void RenderShadow(CommandBuffer cmd, RenderTargetIdentifier shadowMap)
		{
			if (lightShadows == LightShadows.None)
			{
				return;
			}

			Reset();

			var meshBuilder = new MeshBuilder();
			int count = Physics2D.OverlapCircleNonAlloc(transform.position, lightDistance, shadowCasters);
			CombineInstance[] combineArr = new CombineInstance[count];

			for (var i = 0; i < count; i++)
			{
				Collider2D caster = shadowCasters[i];
				if (caster is PolygonCollider2D)
				{
					var mesh = PolygonShadowMesh(caster as PolygonCollider2D);
					combineArr[i].mesh = mesh;
					meshBuilder.AddCopiedMesh(mesh);
					mesh.Clear();
				}
			}

			shadowMesh = meshBuilder.ToMesh(shadowMesh);

			if (lightShadows == LightShadows.Soft && shadowSmooth == ShadowSmooth.VolumnLight)
			{
				cmd.SetGlobalFloat("_LightSize", lightVolume);
				cmd.DrawMesh(shadowMesh, Matrix4x4.TRS(transform.position, transform.rotation, transform.localScale),
					shadowMat, 0, 1);
			}
			else
			{
				cmd.DrawMesh(shadowMesh, Matrix4x4.TRS(transform.position, transform.rotation, transform.localScale),
					shadowMat, 0, 0);
				if (lightShadows == LightShadows.Soft && shadowSmooth == ShadowSmooth.Blur)
				{
					GaussianBlur.Blur(smoothRadius, cmd, shadowMap, shadowMap, LightSystem.Instance.gaussianMat);
				}
			}
		}


		private void OnDrawGizmos()
		{
			if (debugLight)
			{
				Gizmos.color = Color.yellow;
				Gizmos.DrawWireSphere(transform.position, lightVolume);
				Gizmos.color = Color.gray;
				Gizmos.DrawWireSphere(transform.position, lightDistance);
			}
		}
	}
}