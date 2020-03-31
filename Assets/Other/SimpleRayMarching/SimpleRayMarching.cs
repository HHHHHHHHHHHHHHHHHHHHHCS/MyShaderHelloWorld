using System.Collections;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using UnityEngine;

[ExecuteInEditMode]
public class SimpleRayMarching : SceneViewFilter
{
    private Material _rayMarchMat;
    private Camera _cam;

    public Shader shader;

    public float maxDistance = 100;
    [Range(1, 300)] public int maxIterations = 30;
    [Range(0.1f, 0.001f)] public float accuracy = 0.001f;

    [Header("Sphere")]
    public Vector4[] spheres;
    public Color spheresColor = Color.white;
    public float sphereSmooth = 1;

    public Material RayMarchMat
    {
        get
        {
            if (!_rayMarchMat && shader)
            {
                _rayMarchMat = new Material(shader)
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
            }

            return _rayMarchMat;
        }
    }

    public Camera Cam
    {
        get
        {
            if (!_cam)
            {
                _cam = GetComponent<Camera>();
            }

            return _cam;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!RayMarchMat)
        {
            Graphics.Blit(src, dest);
            return;
        }

        RayMarchMat.SetMatrix("_CamFrustum", CamFrustum(Cam));
        RayMarchMat.SetMatrix("_CamToWorld", Cam.cameraToWorldMatrix);

        RayMarchMat.SetFloat("_MaxDistance", maxDistance);
        RayMarchMat.SetFloat("_Accuracy", accuracy);
        RayMarchMat.SetFloat("_MaxIterations", maxIterations);

        if (spheres == null)
        {
            spheres = new Vector4[0];
        }
        RayMarchMat.SetVectorArray("_Spheres", spheres);
        RayMarchMat.SetInt("_SpheresNum", spheres.Length);
        RayMarchMat.SetColor("_SphereSColor", spheresColor);
        RayMarchMat.SetFloat("_SphereSmooth", sphereSmooth);


        RenderTexture.active = dest;
        RayMarchMat.SetTexture("_MainTex", src);

        //压入当前的MVP 
        GL.PushMatrix();

        //视野的锥型区域从(0,0,-1) to (1,1,100)
        GL.LoadOrtho();

        //激活pass 用于渲染
        RayMarchMat.SetPass(0);

        //压入一个面片当作模型
        GL.Begin(GL.QUADS);

        //BL
        //unit 是 texture 的编号
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f); //z储存CamFrustum 的 row
        //BR
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        //TR
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        //TL
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();

        //弹出改变MVP
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 TL = (-Vector3.forward - goRight + goUp);
        Vector3 TR = (-Vector3.forward + goRight + goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);
        Vector3 BL = (-Vector3.forward - goRight - goUp);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }
}