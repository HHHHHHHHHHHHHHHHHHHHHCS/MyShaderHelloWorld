using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class ImageEffectCommandBuffer : MonoBehaviour
{
    public Shader effectShader;

    public Material effectMaterial;

    private CommandBuffer cb;

    private void Awake()
    {
        if (effectMaterial == null)
        {
            if (!effectShader)
            {
                return;
            }

            effectMaterial = new Material(effectShader)
            {
                hideFlags = HideFlags.HideAndDontSave
            };
        }

        if (effectMaterial == null)
        {
            return;
        }


        InitCommandBuffer();

        var mainCam = GetComponent<Camera>();
        mainCam.AddCommandBuffer(CameraEvent.AfterEverything, cb);
    }

    private void InitCommandBuffer()
    {
        cb = new CommandBuffer {name = "AfterEverything"};
        cb.BeginSample("MyCommandBuffer");
        cb.Blit(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget, effectMaterial);
        cb.EndSample("MyCommandBuffer");
    }
}