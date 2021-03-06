﻿using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SimpleRayMarching : SceneViewFilter
{
    private Material _rayMarchMat;
    private Camera _cam;

    public Shader shader;

    public float maxDistance = 100;
    [Range(1, 300)] public int maxIterations = 100;
    [Range(0.1f, 0.001f)] public float accuracy = 0.001f;

    [Space(10)] [Header("Light")] public Light directionalLight;

    [Space(10)] [Header("Reflection")] public ReflectionProbe reflectionProbe;
    public int _ReflectionCount = 8;
    public float _ReflectionIntensity = 0.50f;
    public float _EnvRefIntensity = 0.35f;

    [Space(10)] [Header("Shadow")] public float shadowDistance = 10;
    public float shadowIntensity = 3;
    public bool softShadow = true;
    public float softShadowPenumbra = 3;

    [Space(10)] [Header("AO")] public float aoStepSize = 0.1f;
    public int aoIterations = 3;
    public float aoIntensity = 1f;

    [Space(10)] [Header("Sphere")] public Vector4[] spheres;
    public Transform[] spheresRigi;
    [ColorUsage(false, true)] public Color spheresColor = Color.white;
    public float sphereSmooth = 1;

    [Space(10)] [Header("Plane")] public Transform plane;
    [ColorUsage(false, true)] public Color planeColor = Color.white;

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

        //Matrix
        RayMarchMat.SetMatrix("_CamFrustum", CamFrustum(Cam));
        RayMarchMat.SetMatrix("_CamToWorld", Cam.cameraToWorldMatrix);

        //Light
        if (directionalLight == null || directionalLight.type != LightType.Directional)
        {
            RayMarchMat.SetVector("_LightCol", Color.black);
            RayMarchMat.SetVector("_LightDir", Vector3.forward);
            RayMarchMat.SetFloat("_LightIntensity", 0);
        }
        else //(directionalLight.type == LightType.Directional)
        {
            RayMarchMat.SetColor("_LightCol", directionalLight.color);
            RayMarchMat.SetVector("_LightDir", directionalLight.transform.forward);
            RayMarchMat.SetFloat("_LightIntensity", directionalLight.intensity);
        }

        //Reflection
        if (reflectionProbe)
        {
            if (reflectionProbe.mode == ReflectionProbeMode.Baked)
            {
                RayMarchMat.SetTexture("_ReflectionCube"
                    , reflectionProbe.bakedTexture);
            }
            else if (reflectionProbe.mode == ReflectionProbeMode.Custom)
            {
                RayMarchMat.SetTexture("_ReflectionCube"
                    , reflectionProbe.customBakedTexture);
            }
            else if (reflectionProbe.mode == ReflectionProbeMode.Realtime)
            {
                RayMarchMat.SetTexture("_ReflectionCube"
                    , reflectionProbe.realtimeTexture);
            }
        }
        else
        {
            RayMarchMat.SetTexture("_ReflectionCube"
                , Texture2D.blackTexture);
        }

        RayMarchMat.SetVector("_ReflectionData"
            , new Vector3(
                _ReflectionCount, _ReflectionIntensity, _EnvRefIntensity
            ));

        //Shadow
        RayMarchMat.SetVector("_ShadowData"
            , new Vector4(
                shadowDistance, shadowIntensity, softShadowPenumbra, softShadow ? 1f : 0f
            ));

        //AO
        RayMarchMat.SetVector("_AOData"
            , new Vector3(
                aoStepSize, aoIterations, aoIntensity
            ));

        //Render Object
        RayMarchMat.SetFloat("_MaxDistance", maxDistance);
        RayMarchMat.SetFloat("_Accuracy", accuracy);
        RayMarchMat.SetFloat("_MaxIterations", maxIterations);

        //Sphere
        if (spheres != null && spheres.Length > 0)
        {
            RayMarchMat.SetVectorArray("_Spheres", spheres);
            RayMarchMat.SetInt("_SpheresNum", spheres.Length);
        }
        else
        {
            RayMarchMat.SetInt("_SpheresNum", 0);
        }

        if (spheresRigi != null && spheresRigi.Length > 0)
        {
            RayMarchMat.SetVectorArray("_SpheresRigi"
                , spheresRigi.Select(rigi =>
                {
                    if (rigi == null)
                    {
                        return Vector4.zero;
                    }

                    var pos = rigi.transform.position;
                    var col = rigi.GetComponent<SphereCollider>();
                    return new Vector4(pos.x, pos.y, pos.z, col == null ? 0f : col.radius);
                }).ToArray());
        }

        RayMarchMat.SetInt("_SpheresRigiNum", spheresRigi.Length);

        RayMarchMat.SetColor("_SpheresColor", spheresColor);
        RayMarchMat.SetFloat("_SphereSmooth", sphereSmooth);

        //Plane
        if (plane != null)
        {
            var position = plane.position;
            RayMarchMat.SetVector("_PlanePos"
                , new Vector4(position.x, position.y, position.z, 1.0f));
            RayMarchMat.SetVector("_PlaneUp", plane.up);
            RayMarchMat.SetVector("_PlaneColor", planeColor);
        }
        else
        {
            RayMarchMat.SetVector("_PlanePos", Vector4.zero);
        }

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