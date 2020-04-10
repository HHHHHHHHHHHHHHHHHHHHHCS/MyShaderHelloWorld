using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class AsyncCapture : MonoBehaviour
{
    private Queue<AsyncGPUReadbackRequest> requests = new Queue<AsyncGPUReadbackRequest>();

    private void Update()
    {
        while (requests.Count > 0)
        {
            var req = requests.Peek();

            if (req.hasError)
            {
                Debug.Log("GPU readback error detected.");
                requests.Dequeue();
            }
            else if (req.done)
            {
                //需要关闭HDR
                var buffer = req.GetData<Color32>();

                if (Time.frameCount % 10 == 0)
                {
                    SaveBitmap(buffer, req.width, req.height);
                }

                requests.Dequeue();
                Debug.Break();

            }
            else
            {
                break;
            }
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (requests.Count < 8)
        {
            requests.Enqueue(AsyncGPUReadback.Request(src));
        }
        else
        {
            Debug.Log("Too many requests");
        }

        Graphics.Blit(src, dest);
    }

    private void SaveBitmap(NativeArray<Color32> buffer, int width, int height)
    {
        var tex = new Texture2D(width, height, TextureFormat.RGBA32, false);
        tex.SetPixels32(buffer.ToArray());
        tex.Apply();
        File.WriteAllBytes("Assets/Other/AsyncCapture/async.png", ImageConversion.EncodeToPNG(tex));
        Destroy(tex);
        Debug.Log("Save Async");
    }
}