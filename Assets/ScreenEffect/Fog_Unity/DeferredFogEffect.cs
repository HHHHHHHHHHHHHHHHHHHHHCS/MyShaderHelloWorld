using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DeferredFogEffect : MonoBehaviour
{
    public Shader fogShader;

    [NonSerialized]
    private Material fogMaterial;

    [NonSerialized]
    private Camera deferredCamera;

    [NonSerialized]
    private Vector3[] frustumCorners;

    [NonSerialized]
    private Vector4[] vectorArray;


    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (fogMaterial == null)
        {
            deferredCamera = GetComponent<Camera>();
            frustumCorners = new Vector3[4];
            vectorArray = new Vector4[4];
            fogMaterial = new Material(fogShader);
        }
        deferredCamera.CalculateFrustumCorners(
            new Rect(0, 0, 1, 1),
            deferredCamera.farClipPlane,
            deferredCamera.stereoActiveEye,
            frustumCorners);

        vectorArray[0] = frustumCorners[0];
        vectorArray[1] = frustumCorners[3];
        vectorArray[2] = frustumCorners[1];
        vectorArray[3] = frustumCorners[2];
        fogMaterial.SetVectorArray("_FrustumCorners", vectorArray);

        Graphics.Blit(src, dest, fogMaterial);
    }
}
