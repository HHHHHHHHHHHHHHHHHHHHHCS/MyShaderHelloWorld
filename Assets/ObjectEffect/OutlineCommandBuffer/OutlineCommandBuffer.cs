using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class OutlineCommandBuffer : MonoBehaviour
{
    public Renderer[] renderers;
    public Material outlineMaterial;

    [Range(1, 10)]
    public int blurIterator = 5;
    [Range(1, 10)]
    public int blurSize = 1;
    public bool hardSide;
    public Color outlineColor = Color.black;

    private CommandBuffer commandBuffer;
    private RenderTexture srcRT;
    private Camera mainCam;


    private void Awake()
    {
        mainCam = Camera.main;
        commandBuffer = new CommandBuffer();
        srcRT = RenderTexture.GetTemporary(mainCam.pixelWidth, mainCam.pixelHeight);
        commandBuffer.SetRenderTarget(srcRT);
        commandBuffer.ClearRenderTarget(true,true,Color.black);//初始化 清理RT
        foreach (var renderer in renderers)
        {
            commandBuffer.DrawRenderer(renderer,outlineMaterial);
        }

        outlineMaterial.SetTexture("_SrcTex", srcRT);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        outlineMaterial.SetColor("_OutlineColor",outlineColor);
        outlineMaterial.SetInt("_BlurSize", blurSize);


        Graphics.ExecuteCommandBuffer(commandBuffer);

        int rtW = mainCam.pixelWidth;
        int rtH = mainCam.pixelHeight;
        //深度缓冲位（0,16或24）。请注意，只有24位深度具有模板缓冲区。
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 16);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 16);
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
