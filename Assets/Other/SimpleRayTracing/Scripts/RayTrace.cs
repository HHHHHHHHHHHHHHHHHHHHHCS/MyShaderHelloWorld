using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteInEditMode]
public class RayTrace : MonoBehaviour
{
    private static readonly int VerticesID = Shader.PropertyToID("_Vertices");
    private static readonly int HDRColorID = Shader.PropertyToID("_HDRColor");
    private static readonly int RefractedColorID = Shader.PropertyToID("_RefractedColor");
    private static readonly int ReflectedColorID = Shader.PropertyToID("_ReflectedColor");
    private static readonly int LightPosID = Shader.PropertyToID("_LightPos");
    private static readonly int LightColorID = Shader.PropertyToID("_LightColor");
    private static readonly int MagicTextureID = Shader.PropertyToID("_MagicTexture");
    private static readonly int MagicOriginID = Shader.PropertyToID("_MagicOrigin");
    private static readonly int MagicAlphaID = Shader.PropertyToID("_MagicAlpha");
    private static readonly int SkyBoxID = Shader.PropertyToID("_SkyBox");

    public Transform root;

    public Material material;

    [ColorUsage(false, true)] public Color hdrColor;
    [ColorUsage(false)] public Color refractedColor;
    [ColorUsage(false)] public Color reflectedColor;

    public Light pointLight;
    [ColorUsage(false)] public Color lightColor;

    public Transform magicCircle;
    public Texture2D magicTexture;

    private float magicAlpha;
    private List<GameObject> models;
    private List<Vector4> boundingSphere;

    private void OnEnable()
    {
        AddModels();
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

    private void AddModels()
    {
        if (models == null)
        {
            models = new List<GameObject>();
        }

        if (root == null)
        {
            return;
        }

        models.Clear();
        foreach (var item in root.GetComponentsInChildren<MeshRenderer>().Select(x => x.gameObject))
        {
            models.Add(item);
        }
    }

    private void CalculateBoundingSphere()
    {
        boundingSphere = new List<Vector4>();

        if (models == null)
        {
            return;
        }

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
            if (!model)
            {
                continue;
            }

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
            Vector3 origin = localToWorld.MultiplyPoint((Vector3) boundingSphere[count]);

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
                    case "Floor":
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

        if (list.Count > 0)
        {
            material.SetVectorArray(VerticesID, list);
        }

        material.SetColor(HDRColorID, hdrColor);
        material.SetColor(ReflectedColorID, reflectedColor);
        material.SetColor(RefractedColorID, refractedColor);


        if (pointLight)
        {
            material.SetVector(LightPosID, pointLight.transform.position);
            material.SetColor(LightColorID, lightColor);
        }

        if (magicCircle)
        {
            material.SetVector(MagicOriginID, magicCircle.position);
            material.SetFloat(MagicAlphaID, magicAlpha);
            material.SetTexture(MagicTextureID, magicTexture);
        }

        if (RenderSettings.skybox)
        {
            material.SetTexture(SkyBoxID, RenderSettings.skybox.GetTexture("_Tex"));
        }
    }

    public void SetMagicAlpha(float alpha)
    {
        magicAlpha = alpha;
    }
}