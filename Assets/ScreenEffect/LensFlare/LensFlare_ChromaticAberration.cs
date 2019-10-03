using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LensFlare_ChromaticAberration : MonoBehaviour
{
    [Range(0, 0.025f)] public float amount;
    public Texture texture;
    private Material material;

    private void Awake()
    {
        material = new Material(Shader.Find("HCS/S_LensFlare_ChromaticAberration"));
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!texture)
        {
            Graphics.Blit(src, dest);
            return;
        }

        material.SetTexture("_ChromaticAberration_Spectrum", texture);
        material.SetFloat("_ChromaticAberration_Amount", amount);
        Graphics.Blit(src, dest, material);
    }
}