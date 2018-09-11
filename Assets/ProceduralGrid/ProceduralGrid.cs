using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralGrid : MonoBehaviour
{
    public int xSize, ySize;

    private Vector3[] vertices;
    private Mesh mesh;

    private void Awake()
    {
        StartCoroutine(Generate());
    }

    private IEnumerator Generate()
    {
        WaitForSeconds wait = new WaitForSeconds(0.1f);

        var mesh = GetComponent<MeshFilter>().mesh = new Mesh();
        mesh.name = "Procedural Grid";

        vertices = new Vector3[(xSize + 1) * (ySize + 1)];

        for (int i = 0, y = 0; y <= ySize; y++)
        {
            for (int x = 0; x <= xSize; x++, i++)
            {
                vertices[i] = new Vector3(x, y);
                //yield return wait;
            }
        }

        mesh.vertices = vertices;

        int[] triangles = new int[(ySize + 1) * (xSize + 1) * 6];

        for (int y = 0; y <= ySize; y++)
        {
            for (int x = 0; x <= xSize; x++)
            {
                int pos = 6 * y * xSize + 6 * x;
                int xpos = (xSize + 1) * y + x;
                triangles[pos] = xpos;
                triangles[pos + 3] = triangles[pos + 2] = xpos + 1;
                triangles[pos + 4] = triangles[pos + 1] = xpos + xSize + 1;
                triangles[pos + 5] = xpos + xSize + 2;
                mesh.triangles = triangles;
                yield return wait;
            }
        }

    }

    private void OnDrawGizmos()
    {
        if (vertices == null)
        {
            return;
        }
        Gizmos.color = Color.black;
        for (int i = 0; i < vertices.Length; i++)
        {
            Gizmos.DrawSphere(vertices[i], 0.1f);
        }
    }
}
