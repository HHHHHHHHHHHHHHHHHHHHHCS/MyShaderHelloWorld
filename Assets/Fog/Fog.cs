using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fog : PostEffectsBase
{
    public Shader fogShader;
    private Material fogMaterial = null;

    public Material Mat
    {
        get
        {
            if(fogMaterial==null)
            {
                fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
            }
            return fogMaterial;
        }
    }


    private Camera myCamera;
    public Camera Cam
    {
        get
        {
            if(myCamera==null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }


    private Transform myCamTs;
    public Transform Ts
    {
        get
        {
            if(myCamTs==null)
            {
                myCamTs = GetComponent<Transform>();
            }
            return myCamTs;
        }
    }

    [Range(0, 3f)]
    public float fogDensity = 1f;

    public Color fogColor = Color.white;

    public float fogStart = 0f;
    public float fogEnd = 2f;

    private void OnEnable()
    {
        Cam.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat!=null)
        {
            Matrix4x4 frustmCorners = Matrix4x4.identity;

            float fov = Cam.fieldOfView;
            float near = Cam.nearClipPlane;
            float far = Cam.farClipPlane;
            float aspect = Cam.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = Ts.right * halfHeight * aspect;
            Vector3 toTop = Ts.up * halfHeight;

            Vector3 topLeft = Ts.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;
            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = Ts.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = Ts.forward * near- toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = Ts.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustmCorners.SetRow(0, bottomLeft);
            frustmCorners.SetRow(1, bottomRight);
            frustmCorners.SetRow(2, topRight);
            frustmCorners.SetRow(3, topLeft);

            Mat.SetMatrix("_FrustumCornersRay", frustmCorners);
            Mat.SetMatrix("_ViewProjectionInverseMatrix", (Cam.projectionMatrix
                *Cam.worldToCameraMatrix).inverse);
            Mat.SetFloat("_FogDensity", fogDensity);
            Mat.SetColor("_FogColor", fogColor);
            Mat.SetFloat("_FogStart", fogStart);
            Mat.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, Mat);

        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
