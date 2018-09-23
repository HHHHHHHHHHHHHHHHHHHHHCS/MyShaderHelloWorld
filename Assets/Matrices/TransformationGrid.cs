using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformationGrid : MonoBehaviour
{
    public Transform prefab;
    public int gridResoulution = 10;

    private Transform[] grid;
    private List<Transformation> transformations;
    private Matrix4x4 transformation;

    private void Awake()
    {
        grid = new Transform[gridResoulution * gridResoulution * gridResoulution];
        for (int i = 0, z = 0; z < gridResoulution; z++)
        {
            for (int y = 0; y < gridResoulution; y++)
            {
                for (int x = 0; x < gridResoulution; x++,i++)
                {
                    grid[i] = CreateGridPoint(x, y, z);
                }
            }
        }
        transformations = new List<Transformation>();
        GetComponents(transformations);
    }

    private void Update()
    {
        UpdateTransformation();
        for (int i=0,z=0;z<gridResoulution;z++)
        {
            for (int y = 0; y < gridResoulution; y++)
            {
                for (int x = 0; x < gridResoulution; x++,i++)
                {
                    grid[i].localPosition = TransformPoint(x, y, z);
                }
            }
        }
    }

    private Transform CreateGridPoint(int x, int y, int z)
    {
        Transform point = Instantiate(prefab);
        point.localPosition = GetCoordinates(x, y, z);
        point.GetComponent<MeshRenderer>().material.color
            = GetColor(x, y, z);
        return point;
    }

    private Vector3 GetCoordinates(int x, int y, int z)
    {
        return new Vector3(
            x - (gridResoulution - 1) * 0.5f,
            y - (gridResoulution - 1) * 0.5f,
            z - (gridResoulution - 1) * 0.5f);
    }

    private Color GetColor(int x, int y, int z)
    {
        return new Color(
            (float)x / gridResoulution,
            (float)y / gridResoulution,
            (float)z / gridResoulution);
    }

    private Vector3 TransformPoint(int x, int y, int z)
    {
        Vector3 coordinates = GetCoordinates(x, y, z);
        return transformation.MultiplyPoint(coordinates);
    }

    private void UpdateTransformation()
    {
        if (transformations.Count > 0)
        {
            transformation = transformations[0].Matrix;
            for (int i = 1; i < transformations.Count; i++)
            {
                transformation = transformations[i].Matrix * transformation;
            }
        }
    }
}
