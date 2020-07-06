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
            triangles = new int[triangleCount * 3];
		}

		public void ResizeVerts(int vertCount)
		{
			Array.Resize(ref vertices, vertCount);
			Array.Resize(ref uv1, vertCount);
			Array.Resize(ref uv2, vertCount);
		}

		public void AddVertsAndTriangles(Vector3[] _vertices, int[] _triangles, Vector2[] _uv1, Vector2[] _uv2)
		{
			if (_vertices.Length + verticesCount > vertices.Length)
			{
				ResizeVerts(_vertices.Length + verticesCount);
			}

			if (_triangles.Length + triangleCount > triangles.Length)
			{
				Array.Resize(ref triangles, _triangles.Length + triangleCount);
			}

			var offset = verticesCount;
			for (var i = 0; i < _vertices.Length; i++)
			{
				vertices[offset + i] = _vertices[i];
				uv1[offset + i] = _uv1[i];
				uv2[offset + i] = _uv2[i];
			}

			for (var i = 0; i < _triangles.Length; i++)
			{
				triangles[triangleCount + i] = _triangles[i] + offset;
			}

			verticesCount += _vertices.Length;
			triangleCount += _triangles.Length;
		}

		public void AddCopiedMesh(Mesh mesh)
		{
			AddVertsAndTriangles(mesh.vertices, mesh.triangles, mesh.uv, mesh.uv2);
		}

		public Mesh ToMesh(Mesh mesh)
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
			return ToMesh(new Mesh());
		}
	}
}