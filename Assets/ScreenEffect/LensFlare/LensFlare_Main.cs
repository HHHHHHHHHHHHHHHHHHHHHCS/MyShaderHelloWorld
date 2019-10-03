using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LensFlare_Main : MonoBehaviour
{
    public enum ChromaticAberrationDistanceFunction : int
    {
        Linear = 0,
        Sqrt = 1,
        Constant = 2,
    }

    private Material material;
    private Material ghostMaterial;
    private Material radialWarpMaterial;
    private Material additiveMaterial;
    private Material aberrationMaterial;
    private Material blurMaterial;

    public float subtract = 0.0f;
    [Range(0, 1)] public float multiply = 1f;
    [Range(0, 6)] public int downsample = 1;
    [Range(0, 8)] public int numberOfGhosts = 5;
    [Range(0, 2)] public float displacement = 0.5f;
    public float fallOff = 8f;
    [Range(0, 0.5f)] public float haloWidth = 0.5f;
    public float haloFalloff = 36;
    public float haloSubtract = 0.1f;

    [Range(0, 64)] public int blurSize = 16;
    [Range(1, 16)] public float sigma = 8;

    [Range(0, 0.1f)] public float chromaticAberration = 0.01f;
    public Texture chromaticAberrationSpectrum = null;

    public ChromaticAberrationDistanceFunction chromaticAberrationDistanceFunction;


    private void OnEnable()
    {
        material = NewMat("HCS/S_LensFlare_SubMul");
        ghostMaterial = NewMat("HCS/S_LensFlare_GhostFeature");
        radialWarpMaterial = NewMat("HCS/S_LensFlare_RadialWrap");
        additiveMaterial = NewMat("HCS/S_LensFlare_Additive");
        aberrationMaterial = NewMat("HCS/S_LensFlare_ChromaticAberration");
        blurMaterial = NewMat("HCS/S_LensFlare_GaussianBlur");
    }

    private Material NewMat(string shaderName)
    {
        return new Material(Shader.Find(shaderName));
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetFloat("_Sub",subtract);
        material.SetFloat("_Mul",multiply);
        RenderTexture downsampled = RenderTexture.GetTemporary(Screen.width>>downsample,Screen.height>>downsample,0,RenderTextureFormat.DefaultHDR);
        Graphics.Blit(src,downsampled,material);
        RenderTexture ghosts = RenderTexture.GetTemporary(Screen.width >> downsample, Screen.height >> downsample, 0, RenderTextureFormat.DefaultHDR);
        ghostMaterial.SetInt("_NumGhost", numberOfGhosts);
        ghostMaterial.SetFloat("Displace",displacement);
        ghostMaterial.SetFloat("_Falloff",fallOff);
        Graphics.Blit(downsampled,ghosts,ghostMaterial);
        RenderTexture radialWarped =
            RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.DefaultHDR);

        radialWarpMaterial.SetFloat("_HaloFalloff",haloFalloff);
        radialWarpMaterial.SetFloat("_HaloWidth", haloWidth);
        radialWarpMaterial.SetFloat("_HaloSub", haloSubtract);
        Graphics.Blit(src,radialWarped,radialWarpMaterial);

        additiveMaterial.SetTexture("_MainTex1",radialWarped);

        RenderTexture added =
            RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.DefaultHDR);
        Graphics.Blit(ghosts,added,additiveMaterial);

        RenderTexture aberration = RenderTexture.GetTemporary(Screen.width,Screen.height,0,RenderTextureFormat.DefaultHDR);

        aberrationMaterial.SetTexture("_ChromaticAberration_Spectrum", chromaticAberrationSpectrum);
        aberrationMaterial.SetFloat("_ChromaticAberration_Amount", chromaticAberration);
        aberrationMaterial.SetInt("_Distance_Function", (int)chromaticAberrationDistanceFunction);
        Graphics.Blit(added, aberration, aberrationMaterial);

        RenderTexture blur = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.DefaultHDR);
        blurMaterial.SetInt("_BlurSize", blurSize);
        blurMaterial.SetFloat("_Sigma", sigma);
        blurMaterial.SetInt("_Direction", 1);
        Graphics.Blit(aberration, blur, blurMaterial);

        RenderTexture blur1 = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.DefaultHDR);
        blurMaterial.SetInt("_Direction", 0);
        Graphics.Blit(blur, blur1, blurMaterial);

        additiveMaterial.SetTexture("_MainTex1", blur1);
        Graphics.Blit(src, dest, additiveMaterial);

        RenderTexture.ReleaseTemporary(downsampled);
        RenderTexture.ReleaseTemporary(ghosts);
        RenderTexture.ReleaseTemporary(radialWarped);
        RenderTexture.ReleaseTemporary(added);
        RenderTexture.ReleaseTemporary(aberration);
        RenderTexture.ReleaseTemporary(blur);
        RenderTexture.ReleaseTemporary(blur1);
    }
}