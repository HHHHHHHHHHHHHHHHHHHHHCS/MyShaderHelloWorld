using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class DepthOfFieldEffect : MonoBehaviour
{
    [Range(0.1f, 100f)]
    public float focusDistance = 10f;
    [Range(0.1f, 10f)]
    public float focusRange = 3f;

    [HideInInspector]
    public Shader dofShader;

    [NonSerialized]
    private Material dofMaterial;

    private const int circleOfConfusionPass = 0;
    private const int bokehPass = 1;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!dofMaterial)
        {
            dofMaterial = new Material(dofShader);
            dofMaterial.hideFlags = HideFlags.HideAndDontSave;
        }

        dofMaterial.SetFloat("_FocusDistance", focusDistance);
        dofMaterial.SetFloat("_FocusRange", focusRange);

        RenderTexture coc = RenderTexture.GetTemporary(
            src.width, src.height, 0, RenderTextureFormat.RHalf
            , RenderTextureReadWrite.Linear);


        Graphics.Blit(src, coc, dofMaterial, circleOfConfusionPass);

        Graphics.Blit(src, dest, dofMaterial, bokehPass);


        RenderTexture.ReleaseTemporary(coc);
    }
}
