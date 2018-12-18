using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    
    public Material material
    {
        get
        {
            if(briSatConMaterial==null)
            {
                briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            }
            return briSatConMaterial;
        }
    }

    [Range(0,3)]
    public float brightness = 1.0f;

    [Range(0, 3)]
    public float saturation = 1.0f;

    [Range(0, 3)]
    public float contrast = 1.0f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
