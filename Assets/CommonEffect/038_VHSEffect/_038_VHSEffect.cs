using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class _038_VHSEffect : MonoBehaviour
{
    public Texture2D secondaryTex;

    private Material mat;


    private void Awake()
    {
        mat = new Material(Shader.Find("CommonEffect/S_038_VHSEffect"));
        mat.SetTexture("_SecondaryTex", secondaryTex);
        mat.SetFloat("_OffsetPosY", 0f);
        mat.SetFloat("_OffsetColor", 0.01f);
        mat.SetFloat("_OffsetDistortion", 480f);
        mat.SetFloat("_Intensity", 0.64f);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        mat.SetFloat("OffsetNoiseX", Random.Range(0f, 0.6f));
        float offsetNoise = mat.GetFloat("_OffsetNoiseY");
        mat.SetFloat("_OffsetNoiseY", offsetNoise + Random.Range(-0.03f, 0.03f));

        float offsetPosY = mat.GetFloat("_OffsetPosY");
        if (offsetPosY > 0.0f)
        {
            mat.SetFloat("_OffsetPosY", offsetPosY - Random.Range(0f, offsetPosY));
        }
        else if (offsetPosY < 0.0f)
        {
            mat.SetFloat("_OffsetPosY", offsetPosY + Random.Range(0f, -offsetPosY));
        }
        else if (Random.Range(0, 150) == 1)
        {
            mat.SetFloat("_OffsetPosY", Random.Range(-0.5f, 0.5f));
        }

        float offsetColor = mat.GetFloat("_OffsetColor");
        if (offsetColor > 0.003f)
        {
            mat.SetFloat("_OffsetColor", offsetColor - 0.001f);
        }
        else if (Random.Range(0, 400) == 1)
        {
            mat.SetFloat("_OffsetColor", Random.Range(0.003f, 0.1f));
        }

        if (Random.Range(0, 15) == 1)
        {
            mat.SetFloat("_OffsetDistortion", Random.Range(1f, 480f));
        }
        else
        {
            mat.SetFloat("_OffsetDistortion", 480f);
        }

        Graphics.Blit(src, dest, mat);
    }
}