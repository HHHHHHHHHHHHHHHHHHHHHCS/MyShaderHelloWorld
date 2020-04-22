using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class CheckerboardRendering : MonoBehaviour
{
    public bool offon;

    public CameraEvent evt0, evt1, evt2;

    public Shader blitCameraMotionVectorsShader;
    public Shader checkerboardRenderingShader;


    public RenderTexture rt0, rt1, motionRT;

    private Camera mainCam;

    private Material blitCameraMotionVectorsMaterial;
    private Material checkerboardRenderingMaterial;

    private CommandBuffer cb0, cb1, cb2;

    private int frame = 0;

    private void Awake()
    {
        if (!offon)
        {
            return;
        }

        blitCameraMotionVectorsMaterial = new Material(blitCameraMotionVectorsShader);
        checkerboardRenderingMaterial = new Material(checkerboardRenderingShader);

        mainCam = GetComponent<Camera>();
        mainCam.allowMSAA = true;

        cb0 = new CommandBuffer();
        cb1 = new CommandBuffer();
        cb2 = new CommandBuffer();

        mainCam.AddCommandBuffer(evt0, cb0);
        mainCam.AddCommandBuffer(evt1, cb1);
        mainCam.AddCommandBuffer(evt2, cb2);


        mainCam.renderingPath = RenderingPath.Forward;
        //DepthTextureMode.MotionVectors 游戏场景多半都是动态的
        mainCam.depthTextureMode |= DepthTextureMode.MotionVectors | DepthTextureMode.Depth;

        rt0 = new RenderTexture(Screen.width / 2, Screen.height / 2, 16, RenderTextureFormat.ARGB32,
            RenderTextureReadWrite.Linear);
        rt0.antiAliasing = 2;
        rt0.mipMapBias = -0.5f;
        //自定义解析antiAliasing
        rt0.bindTextureMS = true;
        rt0.name = "RT0";

        rt1 = new RenderTexture(Screen.width / 2, Screen.height / 2, 16, RenderTextureFormat.ARGB32,
            RenderTextureReadWrite.Linear);
        rt1.antiAliasing = 2;
        rt1.mipMapBias = -0.5f;
        //自定义解析antiAliasing
        rt1.bindTextureMS = true;
        rt1.name = "RT1";

        motionRT = new RenderTexture(Screen.width / 2, Screen.height / 2, 0, RenderTextureFormat.RGHalf);
        motionRT.name = "Motion Frame";


        cb0.Clear();
        cb0.BeginSample("CB0");
        cb0.SetGlobalInt("_FrameCnt", frame);
        cb0.Blit(BuiltinRenderTextureType.CameraTarget, frame == 0 ? rt0 : rt1);
        cb0.EndSample("CB0");


        cb1.Clear();
        cb1.BeginSample("CB1");
        cb1.Blit(BuiltinRenderTextureType.MotionVectors, motionRT, blitCameraMotionVectorsMaterial);
        cb1.EndSample("CB1");

        cb2.Clear();
        cb2.BeginSample("CB2");
        cb2.SetGlobalTexture("_RT0", rt0);
        cb2.SetGlobalTexture("_RT1", rt1);
        cb2.SetGlobalTexture("_MotionTexture", motionRT);
        cb2.Blit(null, BuiltinRenderTextureType.CameraTarget, checkerboardRenderingMaterial);
        cb2.EndSample("CB2");
    }

    private void Update()
    {
        if (!offon)
        {
            return;
        }

        frame = (frame + 1) % 2;

        Rect camRect = mainCam.pixelRect;
        camRect.x = frame == 0 ? 0.25f : 0.75f;
        mainCam.pixelRect = camRect;



        cb0.Clear();
        cb0.BeginSample("CB0");
        cb0.SetGlobalInt("_FrameCnt", frame);
        cb0.Blit(BuiltinRenderTextureType.CameraTarget, frame == 0 ? rt0 : rt1);
        cb0.EndSample("CB0");

    }
}