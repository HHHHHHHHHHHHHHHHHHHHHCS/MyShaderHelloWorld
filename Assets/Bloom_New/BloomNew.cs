using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BloomNew : MonoBehaviour
{
    [Range(1, 16)]
    public int iterations = 1;
    public Shader bloomShader;

    [NonSerialized]
    private Material bloom;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!bloom)
        {
            bloom = new Material(bloomShader);
            bloom.hideFlags = HideFlags.HideAndDontSave;
        }


        RenderTexture currentSource = Blur02(source, destination);





        Graphics.Blit(currentSource, destination, bloom);
        RenderTexture.ReleaseTemporary(currentSource);
    }

    private RenderTexture Blur00(RenderTexture source, RenderTexture destination)
    {
        int width = source.width;
        int height = source.height;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = RenderTexture.GetTemporary(
            width, height, 0, format);

        Graphics.Blit(source, currentDestination, bloom);
        RenderTexture currentSource = currentDestination;

        width /= 2 << iterations;
        height /= 2 << iterations;

        width = Mathf.Max(2, width);
        height = Mathf.Max(2, height);

        currentDestination = RenderTexture.GetTemporary(width, height, 0, format);
        Graphics.Blit(currentSource, currentDestination, bloom);
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

        Graphics.Blit(source, currentDestination, bloom);
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
            Graphics.Blit(currentSource, currentDestination, bloom);
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

        Graphics.Blit(source, currentDestination, bloom);
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
            Graphics.Blit(currentSource, currentDestination, bloom);
            //RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        for(i -=2;i>=0;i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        return currentSource;
    }
}
