using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DOF : PostEffectsBase
{
    public Shader replaceShader;

    private Material mat;
    public Material Mat
    {
        get
        {
            if(!mat)
            {
                mat = CheckShaderAndCreateMaterial(replaceShader, mat);
            }
            return mat;
        }
    }


    private Camera cam;
    public Camera Cam
    {
        get
        {
            if(!cam)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }


    protected override void Start()
    {
        base.Start();
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    private void LateUpdate()
    {
        //if(Cam&&replaceShader)
        //{
        //    Cam.RenderWithShader(replaceShader, "RenderType");
        //}
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat)
        {
            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
