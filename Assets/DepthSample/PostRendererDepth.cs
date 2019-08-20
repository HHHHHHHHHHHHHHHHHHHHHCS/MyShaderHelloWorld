﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostRendererDepth : MonoBehaviour
{
    public Material mat;

    private void Awake()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src,dest,mat);
    }
}
