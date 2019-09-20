using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthOfFieldSample : MonoBehaviour
{
    public Material blurMat;
    public Material dofMat;

    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (blurMat != null && dofMat != null)
        {
            RenderTexture blurTex = RenderTexture.GetTemporary(source.width, source.height, 16);
            Graphics.Blit(source, blurTex, blurMat);
            dofMat.SetTexture("_BlurTex", blurTex);
            Graphics.Blit(source, destination, dofMat);
            RenderTexture.ReleaseTemporary(blurTex);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
