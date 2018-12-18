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

    private const int outlinePass = 0;
    private const int onePass = 1;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (depthLightMaterial == null)
        {
            GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
            depthLightMaterial = new Material(depthLightShader);
            depthLightShader.hideFlags = HideFlags.HideAndDontSave;
        }

        RenderTexture depthTexture = RenderTexture.GetTemporary(
            src.width, src.height, 0, src.format);
        Graphics.Blit(src, depthTexture, depthLightMaterial, outlinePass);

        depthLightMaterial.SetTexture("_OutlineTexture", depthTexture);

        RenderTexture lightTexture = RenderTexture.GetTemporary(
            src.width, src.height, 0, src.format);
        Graphics.Blit(src, lightTexture, depthLightMaterial, onePass);


        Graphics.Blit(depthTexture, dest);
        Graphics.Blit(lightTexture, dest);

        RenderTexture.ReleaseTemporary(depthTexture);
        RenderTexture.ReleaseTemporary(lightTexture);
    }
}
