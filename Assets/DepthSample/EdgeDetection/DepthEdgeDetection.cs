using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthEdgeDetection : MonoBehaviour
{
    public enum EdgeType
    {
        Depth = 0,
        DeferredNormal,
        DepthNormal,
    };

    public EdgeType edgeType;

    public Material mat;

    private void Awake()
    {
        //Forward
        //sampler2D _CameraDepthNormalsTexture;
        //Deferred
        //sampler2D _CameraNormalsTexture;
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat)
        {
            Graphics.Blit(src, dest, mat, (int) edgeType);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}