using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurDepth : MonoBehaviour
{
    public Material mat;

    private Matrix4x4 lastVP;

    private Matrix4x4 VPMatrix => Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;

    private void Start()
    {
        lastVP = VPMatrix;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat != null)
        {
            Matrix4x4 currentVP = VPMatrix;
            Matrix4x4 currentInverseVP = VPMatrix.inverse;

            mat.SetMatrix("_CurrentInverseVP", currentInverseVP);
            mat.SetMatrix("_LastVP", lastVP);

            lastVP = currentVP;
            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}