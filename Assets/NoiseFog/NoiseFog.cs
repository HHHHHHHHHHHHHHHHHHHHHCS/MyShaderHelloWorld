using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseFog : PostEffectsBase
{
    public Shader fogShader;
    private Material fogMaterial;


    public Material Mat
    {
        get
        {
            fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
            return fogMaterial;
        }
    }

    private Camera cam;
    public Camera Cam
    {
        get
        {
            if(cam==null)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }

    private Transform camTs;
    public Transform CamTs
    {
        get
        {
            if (camTs == null)
            {
                camTs = Cam.transform;
            }

            return camTs;
        }
    }
    [Range(0.1f, 3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    public Texture noiseTexture;

    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;

    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;

    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;

    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = Cam.fieldOfView;
            float near = Cam.nearClipPlane;
            float aspect = Cam.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = CamTs.right * halfHeight * aspect;
            Vector3 toTop = CamTs.up * halfHeight;

            Vector3 topLeft = CamTs.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CamTs.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CamTs.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CamTs.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            Mat.SetMatrix("_FrustumCornersRay", frustumCorners);

            Mat.SetFloat("_FogDensity", fogDensity);
            Mat.SetColor("_FogColor", fogColor);
            Mat.SetFloat("_FogStart", fogStart);
            Mat.SetFloat("_FogEnd", fogEnd);

            Mat.SetTexture("_NoiseTex", noiseTexture);
            Mat.SetFloat("_FogXSpeed", fogXSpeed);
            Mat.SetFloat("_FogYSpeed", fogYSpeed);
            Mat.SetFloat("_NoiseAmount", noiseAmount);

            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }


}
