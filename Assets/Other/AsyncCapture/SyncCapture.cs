using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SyncCapture : MonoBehaviour
{
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Time.frameCount % 10 == 0)
        {
            var tempRT = RenderTexture.GetTemporary(src.width, src.height);
            Graphics.Blit(src, tempRT);

            var tempTex = new Texture2D(src.width, src.height, TextureFormat.RGBA32, false);
            RenderTexture.active = tempRT;
            tempTex.ReadPixels(new Rect(0, 0, src.width, src.height), 0, 0, false);
            tempTex.Apply();

            File.WriteAllBytes("Assets/Other/AsyncCapture/sync.png", ImageConversion.EncodeToPNG(tempTex));

            Destroy(tempTex);
            RenderTexture.ReleaseTemporary(tempRT);
            Debug.Log("Save Sync");
        }

        Graphics.Blit(src, dest);
    }
}