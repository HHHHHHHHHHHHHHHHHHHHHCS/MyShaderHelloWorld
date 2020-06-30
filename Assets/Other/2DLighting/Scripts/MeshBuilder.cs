using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Lighting2D
{
	public class MeshBuilder
	{
		public Vector3[] vertices;
		public int[] triangles;
		public Vector2[] uv1;
		public Vector2[] uv2;

		private int verticesCount = 0;
		private int triangleCount = 0;

		public MeshBuilder() : this(0, 0)
		{
		}

		public MeshBuilder(int vertCount, int triangleCount)
		{
			vertices = new Vector3[vertCount];
			uv1 = new Vector2[vertCount];
			uv2 = new Vector2[vertCount];
			uv2 = new Vector2[triangleCount * 3];
		}

		public void ResizeVerts(int vertCount)
		{
			Array.Resize(ref vertices, verticesCount);
			Array.Resize(ref uv1, vertCount);
			Array.Resize(ref uv2, vertCount);
		}

		public void AddVertsAndTriangles(Vector3[] vertices, int[] triangles, Vector2[] uv1, Vector2[] uv2)
		{
			if (vertices.Length + verticesCount > vertices.Length)
			{
				ResizeVerts(vertices.Length + verticesCount);
			}

			if (triangles.Length + triangleCount > triangles.Length)
			{
				Array.Resize(ref triangles, triangles.Length + triangleCount);
			}

			var offset = verticesCount;
			for (var i = 0; i < vertices.Length; i++)
			{
				vertices[offset + i] = vertices[i];
				uv1[offset + i] = uv1[i];
				uv2[offset + i] = uv2[i];
			}

			for (var i = 0; i < triangles.Length; i++)
			{
				this.triangles[triangleCount + i] = triangles[i] + offset;
			}

			verticesCount += vertices.Length;
			triangleCount += triangles.Length;
		}

		public void AddCopiedMesh(Mesh mesh)
		{
			AddVertsAndTriangles(mesh.vertices, mesh.triangles, mesh.uv, mesh.uv2);
		}

		public Mesh toMesh(Mesh mesh)
		{
			mesh.Clear();
			mesh.vertices = vertices;
			mesh.triangles = triangles;
			mesh.uv = uv1;
			mesh.uv2 = uv2;
			return mesh;
		}

		public Mesh ToMesh()
		{
			return toMesh(new Mesh());
		}
	}
}