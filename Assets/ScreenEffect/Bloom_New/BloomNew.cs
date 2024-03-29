﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BloomNew : MonoBehaviour
{
    public Shader bloomShader;
    [Range(1, 16)]
    public int iterations = 1;
    [Range(0,10)]
    public float threshold = 1;
    [Range(0, 1)]
    public float softThreshold = 0.5f;
    [Range(0, 10)]
    public float intensity = 1;
#if UNITY_EDITOR
    public bool debug;
#endif

    [NonSerialized]
    private Material bloom;

    private const int BoxDownPrefilterPass = 0;
    private const int BoxDownPass = 1;
    private const int BoxUpPass = 2;
    private const int ApplyBloomPass = 3;
    private const int DebugBloomPass = 4;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!bloom)
        {
            bloom = new Material(bloomShader);
            bloom.hideFlags = HideFlags.HideAndDontSave;
        }

        bloom.SetFloat("_Intensity", Mathf.GammaToLinearSpace(intensity));

        float knee = threshold * softThreshold;
        Vector4 filter;
        filter.x = threshold;
        filter.y = filter.x - knee;
        filter.z = 2f * knee;
        filter.w = 0.25f / (knee + 0.00001f);
        bloom.SetVector("_Filter", filter);


        RenderTexture currentSource = Blur02(source, destination);

#if UNITY_EDITOR
        if (debug)
        {
            Graphics.Blit(currentSource, destination, bloom, DebugBloomPass);
        }
        else
        {
#endif
            bloom.SetTexture("_SourceTex", source);
            Graphics.Blit(currentSource, destination, bloom, ApplyBloomPass);

#if UNITY_EDITOR
        }
#endif
        RenderTexture.ReleaseTemporary(currentSource);
    }

    private RenderTexture Blur00(RenderTexture source, RenderTexture destination)
    {
        int width = source.width;
        int height = source.height;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = RenderTexture.GetTemporary(
            width, height, 0, format);

        Graphics.Blit(source, currentDestination, bloom, BoxDownPrefilterPass);
        RenderTexture currentSource = currentDestination;

        width /= 2 << iterations;
        height /= 2 << iterations;

        width = Mathf.Max(2, width);
        height = Mathf.Max(2, height);

        currentDestination = RenderTexture.GetTemporary(width, height, 0, format);
        Graphics.Blit(currentSource, currentDestination, bloom, BoxDownPass);
        RenderTexture.ReleaseTemporary(currentSource);
        currentSource = currentDestination;
        return currentSource;
    }


    private RenderTexture Blur01(RenderTexture source, RenderTexture destination)
    {

        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = RenderTexture.GetTemporary(
            width, height, 0, format);

        Graphics.Blit(source, currentDestination, bloom, BoxDownPrefilterPass);
        RenderTexture currentSource = currentDestination;


        for (int i = 1; i < iterations; i++)
        {
            if (height < 2 || width < 2)
            {
                break;
            }
            width /= 2;
            height /= 2;
            currentDestination = RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(currentSource, currentDestination, bloom, BoxDownPass);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }
        return currentSource;
    }

    private RenderTexture Blur02(RenderTexture source, RenderTexture destination)
    {
        RenderTexture[] textures = new RenderTexture[16];
        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(
            width, height, 0, format);

        Graphics.Blit(source, currentDestination, bloom, BoxDownPrefilterPass);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        for (; i < iterations; i++)
        {
            if (height < 2 || width < 2)
            {
                break;
            }
            width /= 2;
            height /= 2;
            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(currentSource, currentDestination, bloom, BoxDownPass);
            //RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        for (i -= 2; i >= 0; i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination, bloom, BoxUpPass);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        return currentSource;
    }
}
