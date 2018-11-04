using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode,ImageEffectAllowedInSceneView]
public class FXAAEffect : MonoBehaviour
{
    [HideInInspector]
    public Shader fxaaShader;

    [NonSerialized]
    private Material fxaaMaterial;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(fxaaMaterial==null)
        {
            fxaaMaterial = new Material(fxaaShader);
            fxaaMaterial.hideFlags = HideFlags.HideAndDontSave;
        }

        Graphics.Blit(src, dest, fxaaMaterial);
    }
}
