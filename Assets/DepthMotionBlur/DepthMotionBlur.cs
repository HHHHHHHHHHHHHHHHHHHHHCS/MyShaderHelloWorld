using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthMotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial;

    public Material Mat
    {
        get
        {
            if(motionBlurMaterial==null)
            {
                motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            }
            return motionBlurMaterial;
        }
    }

    [Range(0, 1f)]
    public float blurSize = 0.5f;


    private Camera myCamera;
    public Camera Cam
    {
        get
        {
            if(myCamera==null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    private Matrix4x4 previousViewProjectionMatrix;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Mat==null)
        {
            Mat.SetFloat("_BlurSize", blurSize);

            Mat.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 newMatrix = Cam.projectionMatrix * Cam.worldToCameraMatrix;
            Matrix4x4 inverseMatrix = newMatrix.inverse;
            Mat.SetMatrix("_CurrentViewProjectInverseMatrix", inverseMatrix);
            previousViewProjectionMatrix = newMatrix;
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
