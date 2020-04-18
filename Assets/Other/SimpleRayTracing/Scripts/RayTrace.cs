using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RayTrace : MonoBehaviour
{
    private static readonly int VerticesID = Shader.PropertyToID("_Vertices");
    private static readonly int LightPosID = Shader.PropertyToID("_LightPos");
    private static readonly int MagicOriginID = Shader.PropertyToID("_MagicOrigin");
    private static readonly int MagicAlphaID = Shader.PropertyToID("_MagicAlpha");


    public List<GameObject> models;

    public Material material;

    public Light pointLight;

    public Transform magicCircle;

    public float magicAlpha;

    private List<Vector4> boundingSphere;

    private void OnEnable()
    {
        CalculateBoundingSphere();
    }

    private void Update()
    {
        if (material)
        {
            SetRenderData();
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private void CalculateBoundingSphere()
    {
        boundingSphere = new List<Vector4>();

        foreach (var model in models)
        {
            MeshFilter mf = model.GetComponent<MeshFilter>();
            if (!mf)
            {
                continue;
            }

            Mesh mesh = mf.sharedMesh;

            if (!mesh)
            {
                continue;
            }

            float maxX = -Mathf.Infinity,
                maxY = -Mathf.Infinity,
                maxZ = -Mathf.Infinity,
                minX = Mathf.Infinity,
                minY = Mathf.Infinity,
                minZ = Mathf.Infinity;

            foreach (var vert in mesh.vertices)
            {
                if (vert.x > maxX) maxX = vert.x;
                if (vert.y > maxY) maxY = vert.y;
                if (vert.z > maxZ) maxZ = vert.z;
                if (vert.x < minX) minX = vert.x;
                if (vert.y < minY) minY = vert.y;
                if (vert.z < minZ) minZ = vert.z;
            }

            float x = maxX - minX;
            float y = maxY - minY;
            float z = maxZ - minZ;

            Vector3 origin = new Vector3(0.5f * (maxX + minX), 0.5f * (maxY + minY), 0.5f * (maxZ + minZ));

            float r = 0.5f * Mathf.Max(x, y, z);

            foreach (var vert in mesh.vertices)
            {
                var sqrLen = Vector3.SqrMagnitude(vert - origin);
                if (sqrLen > r * r)
                {
                    r = Mathf.Sqrt(sqrLen);
                }
            }

            boundingSphere.Add(new Vector4(origin.x, origin.y, origin.z, r));
        }
    }

    private void SetRenderData()
    {
        List<Vector4> list = new List<Vector4>();

        int count = 0;

        foreach (var model in models)
        {
            Matrix4x4 localToWorld = model.transform.localToWorldMatrix;

            MeshFilter mf = model.GetComponent<MeshFilter>();
            if (!mf)
            {
                continue;
            }

            Mesh mesh = mf.sharedMesh;

            if (!mesh)
            {
                continue;
            }

            //一个点 通过矩阵变换 新的点
            //这里把origin转到世界坐标
            Vector3 origin = localToWorld.MultiplyPoint(boundingSphere[count]);

            var lossyScale = model.transform.lossyScale;
            float maxScale = Mathf.Max(lossyScale.x, lossyScale.y,
                lossyScale.z);

            list.Add(new Vector4(origin.x, origin.y, origin.z, boundingSphere[count].w * maxScale)); //加入包围球数据
            list.Add(new Vector4(mesh.triangles.Length, 0)); //加入顶点长度数据
            count++;

            foreach (var item in mesh.triangles)
            {
                Vector4 vec = localToWorld.MultiplyPoint(mesh.vertices[item]);

                switch (model.name)
                {
                    case "Diamond":
                        vec.w = 0;
                        break;
                    case "Plane":
                        vec.w = 1;
                        break;
                    case "Trillion":
                        vec.w = 2;
                        break;
                    case "Pyramid":
                        vec.w = 3;
                        break;
                    case "HDRPyramid":
                        vec.w = 4;
                        break;
                    default:
                        vec.w = -1;
                        break;
                }

                list.Add(vec);
            }
        }

        material.SetVectorArray(VerticesID, list);
        material.SetVector(LightPosID, pointLight.transform.position);
        material.SetVector(MagicOriginID, magicCircle.position);
        material.SetFloat(MagicAlphaID, magicAlpha);
    }
}