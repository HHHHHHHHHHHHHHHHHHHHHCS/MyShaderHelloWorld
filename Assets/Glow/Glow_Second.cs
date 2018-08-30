using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glow_Second : PostEffectsBase
{
    public Shader glowShader;
    public Shader blurShader;
    public Shader mixShader;

    private Material mixMat;

    public Material MixMat
    {
        get
        {
            if (!mixMat)
            {
                mixMat = CheckShaderAndCreateMaterial(mixShader, mixMat);
            }
            return mixMat;
        }
    }


    private RenderTexture rt;

    protected override void Start()
    {
        base.Start();

        GameObject obj = transform.Find("CameraRT").gameObject;
        if (!obj)
        {
            obj = new GameObject("CameraRT");

            obj.transform.SetParent(transform, false);

        }


        var mainCam = GetComponent<Camera>();
        rt = new RenderTexture(Screen.width, Screen.height, (int)mainCam.depth);


        var cam = obj.GetComponent<Camera>();
        if(cam==null)
        {
            cam = obj.AddComponent<Camera>();
        }
        cam.enabled = false;
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = Color.black;
        cam.orthographic = mainCam.orthographic;
        cam.orthographicSize = mainCam.orthographicSize;
        cam.nearClipPlane = mainCam.nearClipPlane;
        cam.farClipPlane = mainCam.farClipPlane;
        cam.fieldOfView = mainCam.fieldOfView;
        cam.targetTexture = rt;


        var bloomTex = obj.GetComponent<Glow_Main>();
        if (bloomTex == null)
        {
            bloomTex = obj.AddComponent<Glow_Main>();
        }
        bloomTex.replaceShader = glowShader;
        bloomTex.blurShader = blurShader;




        MixMat.SetTexture("_BlurTex", rt);
    }

    [Range(0.0f, 5.0f)]
    public float mixValue = 1.0f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (MixMat)
        {
            MixMat.SetFloat("_MixValue", mixValue);
            Graphics.Blit(src, dest, MixMat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }

    }
}
