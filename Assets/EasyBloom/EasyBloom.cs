using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EasyBloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material bloomMat;


    public Material Mat
    {
        get
        {
            if(bloomMat==null)
            {
                bloomMat = CheckShaderAndCreateMaterial(bloomShader, bloomMat);
            }
            return bloomMat;
        }
    }


    [Range(1, 10)]
    public int blurRadius = 5;

    [Range(0, 1.0f)]
    public float bloomFactor = 0.5f;

    public Color colorThreshold = new Color(0.5f, 0.5f, 0.5f, 1);

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat!=null)
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
