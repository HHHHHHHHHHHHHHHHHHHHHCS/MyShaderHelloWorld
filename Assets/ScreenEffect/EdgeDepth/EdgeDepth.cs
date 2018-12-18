using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDepth : PostEffectsBase
{
    public Shader edgeDepth;
    private Material material;

    public Material Mat
    {
        get
        {
            if(material==null)
            {
                material = CheckShaderAndCreateMaterial(edgeDepth, material);
            }
            return material;
        }
    }

    [Range(0.0f,1.0f)]
    public float edgeOnly = 0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;


    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat!=null)
        {
            Mat.SetFloat("_EdgeOnly", edgeOnly);
            Mat.SetColor("_EdgeColor", edgeColor);
            Mat.SetColor("_BackgroundColor", backgroundColor);
            Mat.SetFloat("_SampleDistance", sampleDistance);
            Mat.SetVector("_Sensitivity", new Vector4(
                sensitivityNormals, sensitivityDepth,0,0));

            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
