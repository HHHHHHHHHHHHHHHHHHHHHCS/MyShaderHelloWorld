using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZBufferCamera : MonoBehaviour
{
    public Shader shader;

    private Material mat;

    void Start()
    {
        if (shader)
        {
            Camera.main.depthTextureMode |= DepthTextureMode.Depth;
            mat = new Material(shader);
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat)
        {
            Graphics.Blit(src, dest, mat);
        }
    }
}
