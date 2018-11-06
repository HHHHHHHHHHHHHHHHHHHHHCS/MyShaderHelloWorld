using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class DepthAndLight : MonoBehaviour
{
    [HideInInspector]
    public Shader depthLightShader;

    [NonSerialized]
    private Material depthLightMaterial;

    private const int depthPass = 0;
    private const int lightPass = 1;
    private const int mixPass = 2;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (depthLightMaterial == null)
        {
            depthLightMaterial = new Material(depthLightShader);
            depthLightShader.hideFlags = HideFlags.HideAndDontSave;
        }

        RenderTexture depthTexture = RenderTexture.GetTemporary(
            src.width, src.height, 0, src.format);
        Graphics.Blit(src, depthTexture, depthLightMaterial, depthPass);

        RenderTexture lightTexture = RenderTexture.GetTemporary(
            src.width, src.height, 0, src.format);
        Graphics.Blit(src, lightTexture, depthLightMaterial, lightPass);


        //Graphics.Blit(depthTexture, dest);
        Graphics.Blit(lightTexture, dest);

        RenderTexture.ReleaseTemporary(depthTexture);
        RenderTexture.ReleaseTemporary(lightTexture);
    }
}
