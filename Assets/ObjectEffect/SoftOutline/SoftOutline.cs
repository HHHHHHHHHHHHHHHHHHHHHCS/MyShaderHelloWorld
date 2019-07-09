using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoftOutline : MonoBehaviour
{
    public Material outlineMaterial;
    [Range(1, 10)] public int blurIterator = 5;
    [Range(1, 10)] public int blurSize = 1;
    public bool hardSide;
    public Color outlineColor = Color.black;

    private Camera mainCam, rtCam;
    private RenderTexture srcRT;

    private void Awake()
    {
        rtCam = transform.GetChild(0).GetComponent<Camera>();
        mainCam = Camera.main;
        srcRT = RenderTexture.GetTemporary(mainCam.pixelWidth, mainCam.pixelHeight, 0);
        rtCam.targetTexture = srcRT;

        outlineMaterial.SetTexture("_SrcTex", srcRT);
    }

    /*
    private void OnPreRender()
    {
        
    }
    */

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        outlineMaterial.SetColor("_OutlineColor", outlineColor);
        outlineMaterial.SetInt("_BlurSize", blurSize);

        int rtW = mainCam.pixelWidth;
        int rtH = mainCam.pixelHeight;
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 0);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 0);
        // 先模糊纯色的图片
        Graphics.Blit(srcRT, temp1);
        // 模糊迭代
        for (int i = 0; i < blurIterator; i++)
        {
            Graphics.Blit(temp1, temp2, outlineMaterial, 0);
            Graphics.Blit(temp2, temp1, outlineMaterial, 1);
        }

        if (hardSide)
        {
            outlineMaterial.EnableKeyword("_Hard_Side");
        }
        else
        {
            outlineMaterial.DisableKeyword("_Hard_Side");
        }


        outlineMaterial.SetTexture("_BlurTex", temp2);

        Graphics.Blit(src, dest, outlineMaterial, 2);
        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}