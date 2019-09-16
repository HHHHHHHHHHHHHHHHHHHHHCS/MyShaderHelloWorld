using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterFloodedFrustum : MonoBehaviour
{
    public Material mat;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat != null)
        {
            Camera cam = Camera.main;
            float tanHalfFov = Mathf.Tan(0.5f * cam.fieldOfView * Mathf.Deg2Rad);
            float halfHeight = tanHalfFov * cam.nearClipPlane;
            float halfWidth = halfHeight * cam.aspect;

            Vector3 toTop = cam.transform.up * halfHeight;
            Vector3 toRight = cam.transform.right * halfWidth;
            Vector3 toForward = cam.transform.forward * cam.nearClipPlane;

            Vector3 toTopLeft = toForward + toTop - toRight;
            Vector3 toBottomLeft = toForward - toTop - toRight;
            Vector3 toTopRight = toForward + toTop + toRight;
            Vector3 toBottomRight = toForward - toTop + toRight;


            toTopLeft /= cam.nearClipPlane;
            toBottomLeft /= cam.nearClipPlane;
            toTopRight /= cam.nearClipPlane;
            toBottomRight /= cam.nearClipPlane;

            Matrix4x4 frustumDir = Matrix4x4.identity;
            frustumDir.SetRow(0, toBottomLeft);
            frustumDir.SetRow(1, toBottomRight);
            frustumDir.SetRow(2, toTopLeft);
            frustumDir.SetRow(3, toTopRight);
            mat.SetMatrix("_FrustumDir", frustumDir);

            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}