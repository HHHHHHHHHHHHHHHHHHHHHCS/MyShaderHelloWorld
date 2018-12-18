using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

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
            if (!cam)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }


    private void Update()
    {
        if (Cam && replaceShader)
        {
            //RenderWithShader 是一帧替换一次
            Cam.RenderWithShader(replaceShader, "RenderType");
            //SetReplacementShader 是永久替换
            //Cam.SetReplacementShader(replaceShader, "RenderType");
        }
        //GameObject.Find("Canvas/RawImage").GetComponent<RawImage>()
        //    .texture = Cam.targetTexture;
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
