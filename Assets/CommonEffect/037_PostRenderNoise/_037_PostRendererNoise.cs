using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class _037_PostRendererNoise : MonoBehaviour
{
    public Texture2D noiseTexture;

    private Material _mat;

    private void OnEnable()
    {
        _mat = new Material(Shader.Find("CommonEffect/S_037_PostRenderNoise"));
        _mat.SetTexture("_SecondaryTex", noiseTexture);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        _mat.SetFloat("_OffsetX",Random.Range(0,1.1f));
        _mat.SetFloat("_OffsetY", Random.Range(0, 1.1f));
        //_mat.SetFloat("_Intensity", Random.value);
        Graphics.Blit(src,dest,_mat);
    }
}
