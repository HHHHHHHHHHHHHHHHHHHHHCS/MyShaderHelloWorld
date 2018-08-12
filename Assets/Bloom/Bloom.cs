using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material bloomMaterial = null;

    public Material Mat
    {
        get
        {
            if (!bloomMaterial)
            {
                bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            }
            return bloomMaterial;
        }
    }


    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    [Range(0, 4f)]
    public float luminanceThreshold = 0.6f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat != null)
        {
            Mat.SetFloat("_LuminanceThreshold", luminanceThreshold);
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture oldBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            oldBuffer.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, oldBuffer, Mat, 0);

            for (int i = 0; i < iterations; i++)
            {
                Mat.SetFloat("_BlurSize", 1 + i * blurSpread);

                RenderTexture newBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(oldBuffer, newBuffer, Mat, 1);

                RenderTexture.ReleaseTemporary(oldBuffer);
                oldBuffer = newBuffer;
                newBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(oldBuffer, newBuffer, Mat, 2);

                RenderTexture.ReleaseTemporary(oldBuffer);
                oldBuffer = newBuffer;
            }

            Mat.SetTexture("_Bloom", oldBuffer);
            Graphics.Blit(oldBuffer, dest, Mat, 3);

            RenderTexture.ReleaseTemporary(oldBuffer);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
