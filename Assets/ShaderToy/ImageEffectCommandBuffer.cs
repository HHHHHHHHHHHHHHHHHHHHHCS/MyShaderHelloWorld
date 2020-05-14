using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class ImageEffectCommandBuffer : MonoBehaviour
{
    public bool inputMousePos;

    public Shader effectShader;

    public Material effectMaterial;

    private CommandBuffer cb;


    private Camera mainCam;

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

        mainCam = GetComponent<Camera>();
        mainCam.AddCommandBuffer(CameraEvent.AfterEverything, cb);


        effectMaterial.SetVector("_MousePos", new Vector2(0.5f,0.5f));
    }

    private void InitCommandBuffer()
    {
        cb = new CommandBuffer {name = "AfterEverything"};
        cb.BeginSample("MyCommandBuffer");
        cb.Blit(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget, effectMaterial);
        cb.EndSample("MyCommandBuffer");
    }


    private void Update()
    {
        if (inputMousePos && effectMaterial)
        {
            if (Input.GetMouseButton(0))
            {
                Vector2 mousePos = Input.mousePosition;
                Vector2 viewPos = mainCam.ScreenToViewportPoint(mousePos);
                //Debug.Log($"({viewPos.x:F5}, {viewPos.y:F5})");
                effectMaterial.SetVector("_MousePos", viewPos);
            }
        }
    }
}