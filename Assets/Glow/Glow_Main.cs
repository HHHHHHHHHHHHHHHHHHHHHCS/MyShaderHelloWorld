using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glow_Main : PostEffectsBase
{

    public Shader replaceShader;
    public Shader blurShader;
    private Material renderMaterial;


    private Material Mat
    {
        get
        {
            if (!renderMaterial)
            {
                renderMaterial = CheckShaderAndCreateMaterial(blurShader, renderMaterial);
            }
            return renderMaterial;
        }
    }

    private Camera cam;
    public Camera Cam
    {
        get
        {
            if (cam)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }


    private void LateUpdate()
    {
        if (Cam != null && replaceShader != null)
        {
            Cam.RenderWithShader(replaceShader, "RenderType");
        }
    }

    [Range(1, 10)]
    public int blurRadius = 10;

    [Range(0, 1.0f)]
    public float bloomFactor = 1f;

    public Color colorThreshold = new Color(0f, 0f, 0f, 1);

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat)
        {
            Mat.SetInt("_BlurRadius", blurRadius);
            Mat.SetFloat("_BloomFactor", bloomFactor);
            Mat.SetColor("_ColorThreshold", colorThreshold);
            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
