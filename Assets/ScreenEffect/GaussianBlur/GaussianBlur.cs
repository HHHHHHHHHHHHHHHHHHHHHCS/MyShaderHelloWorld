using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gausssianBlurShader;
    private Material gaussianBlurMaterial;

    public Material Mat
    {
        get
        {
            if(gaussianBlurMaterial==null)
            {
                gaussianBlurMaterial = CheckShaderAndCreateMaterial(
                    gausssianBlurShader, gaussianBlurMaterial); 
            }
            return gaussianBlurMaterial;
        }
    }

    [Range(0,4)]
    public int iterations = 3;

    [Range(0.2f,3f)]
    public float blurSpread = 0.6f;

    [Range(1,8)]
    public int downSample = 2;


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture oldBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            oldBuffer.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, oldBuffer);

            for(int i=0;i<iterations;i++)
            {
                Mat.SetFloat("_BlurSize", 1 + i * blurSpread);

                RenderTexture newBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(oldBuffer, newBuffer, Mat, 0);

                RenderTexture.ReleaseTemporary(oldBuffer);
                oldBuffer=newBuffer;
                newBuffer = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(oldBuffer, newBuffer, Mat, 1);

                RenderTexture.ReleaseTemporary(oldBuffer);
                oldBuffer = newBuffer;
            }


            Graphics.Blit(oldBuffer, dest);
            RenderTexture.ReleaseTemporary(oldBuffer);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
