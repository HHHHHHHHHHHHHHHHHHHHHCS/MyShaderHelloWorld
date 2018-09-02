using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustDOF : PostEffectsBase
{
    public Shader blurShader;

    private Material blurMat;
    public Material BlurMat
    {
        get
        {
            if (!blurMat)
            {
                blurMat = CheckShaderAndCreateMaterial(blurShader, blurMat);
            }
            return blurMat;
        }
    }

    public Shader dofShader;

    private Material dofMat;
    public Material DOFMat
    {
        get
        {
            if (!dofMat)
            {
                dofMat = CheckShaderAndCreateMaterial(dofShader, dofMat);
            }
            return dofMat;
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

    [Range(0,1.0f)]
    public float focalDistance = 0.5f;
    [Range(0, 1.0f)]
    public float lerpDistance = 0.2f;

    public int downSample = 1;


    protected override void Start()
    {
        base.Start();
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (BlurMat&& DOFMat)
        {

            RenderTexture blurTex = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);

            Graphics.Blit(src, blurTex, BlurMat);

            DOFMat.SetTexture("_BlurTex", blurTex);
            DOFMat.SetFloat("_FocalDistance", focalDistance);
            DOFMat.SetFloat("_LerpDistance", lerpDistance);

            Graphics.Blit(src, dest, DOFMat);
            
            RenderTexture.ReleaseTemporary(blurTex);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
