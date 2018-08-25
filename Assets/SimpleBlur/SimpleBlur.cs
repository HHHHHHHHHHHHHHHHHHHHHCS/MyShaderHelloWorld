using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleBlur : PostEffectsBase
{
    public Shader blur;
    private Material mat;
    public Material Mat
    {
        get
        {
            if(!mat)
            {
                mat = CheckShaderAndCreateMaterial(blur, mat);
            }
            return mat;
        }
    }

    [Range(1, 10)]
    public int blurRadius=5;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat)
        {
            Mat.SetFloat("_BlurRadius", blurRadius);

            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
