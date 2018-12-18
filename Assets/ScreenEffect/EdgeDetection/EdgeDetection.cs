using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectionShader;

    private Material edgeDetectionMaterial = null;

    public Material material
    {
        get
        {
            if(edgeDetectionMaterial == null)
            {
                edgeDetectionMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader, edgeDetectionMaterial);
            }
            return edgeDetectionMaterial;
        }
    }

    [Range(0,1)]
    public float edgesOnly = 0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
