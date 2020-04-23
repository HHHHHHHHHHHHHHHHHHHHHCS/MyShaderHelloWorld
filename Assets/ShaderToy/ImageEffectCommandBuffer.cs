using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class ImageEffectCommandBuffer : MonoBehaviour
{
    public Shader effectShader;

    private Material effectMaterial;

    private CommandBuffer cb;

    private void Awake()
    {
        if (!effectShader)
        {
            return;
        }

        effectMaterial = new Material(effectShader);

        InitCommandBuffer();

        var mainCam = GetComponent<Camera>();
        mainCam.AddCommandBuffer(CameraEvent.AfterEverything, cb);
    }

    private void InitCommandBuffer()
    {
        cb = new CommandBuffer();
        cb.BeginSample("MyCommandBuffer");
        cb.Blit(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget, effectMaterial);
        cb.EndSample("MyCommandBuffer");
    }

    private void OnDestroy()
    {
        if (effectMaterial)
        {
            GameObject.DestroyImmediate(effectMaterial);
        }
    }
}