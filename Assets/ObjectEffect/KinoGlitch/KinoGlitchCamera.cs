using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class KinoGlitchCamera : MonoBehaviour
{
    public Shader shader;

    [Range(0, 1)] public float scanLineJitter = 0;

    private Material mat;

    private void OnEnable()
    {
        if (!shader)
        {
            return;
        }
        mat = new Material(shader);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!mat)
        {
            return;
        }

        Graphics.Blit(src,dest,mat);
    }
}