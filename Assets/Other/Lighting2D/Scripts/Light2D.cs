using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
	public enum LightType
	{
		Analytical,
		Textured,
	}

	[ExecuteInEditMode]
	public class Light2D : Light2DBase
	{
		public LightType lightType = LightType.Analytical;
		[Range(-1, 1)] public float attenuation;
		public Color lightColor = Color.white;
		public float intensity = 1;
		public Texture lightTexture;
		public Mesh mesh;

		private Material lightMaterial;
		private float lastLightDistance;

		protected string lightShaderName { get; } = "Other/Light2D";

		private void Awake()
		{
			var halfRange = lightDistance / 2;
			mesh = new Mesh();
			mesh.vertices = new Vector3[]
			{
				new Vector3(-halfRange, -halfRange, 0),
				new Vector3(halfRange, -halfRange, 0),
				new Vector3(-halfRange, halfRange, 0),
				new Vector3(halfRange, halfRange, 0),
			};

			mesh.triangles = new int[]
			{
				0, 2, 1,
				2, 3, 1,
			};
			mesh.RecalculateNormals();
			mesh.uv = new Vector2[]
			{
				new Vector2(0, 0),
				new Vector2(1, 0),
				new Vector2(0, 1),
				new Vector2(1, 1),
			};
			mesh.MarkDynamic();
		}

		private void Update()
		{
			UpdateMesh();
		}

		public void UpdateMesh()
		{
			if (lastLightDistance != lightDistance)
			{
				lastLightDistance = lightDistance;
				mesh.vertices = new[]
				{
					new Vector3(-lightDistance, -lightDistance, 0),
					new Vector3(lightDistance, -lightDistance, 0),
					new Vector3(-lightDistance, lightDistance, 0),
					new Vector3(lightDistance, lightDistance, 0),
				};
			}
		}

		public override void RenderLight(CommandBuffer cmd)
		{
			if (!lightMaterial)
			{
				lightMaterial = new Material(Shader.Find(lightShaderName));
			}

			lightMaterial.SetTexture("_MainTex", lightTexture);
			lightMaterial.SetColor("_Color", lightColor);
			lightMaterial.SetFloat("_Attenuation", attenuation);
			lightMaterial.SetFloat("_Intensity", intensity);

			cmd.SetGlobalVector("_2DLightPos", transform.position);
			cmd.SetGlobalFloat("_LightRange", lightDistance);
			cmd.SetGlobalFloat("_Intensity", intensity);
			var trs = Matrix4x4.TRS(transform.position, transform.rotation, transform.localScale);
			switch (lightType)
			{
				case LightType.Analytical:
					cmd.DrawMesh(mesh, trs, lightMaterial, 0, 0);
					break;
				case LightType.Textured:
					cmd.DrawMesh(mesh, trs, lightMaterial, 0, 1);
					break;
			}
		}
	}
}