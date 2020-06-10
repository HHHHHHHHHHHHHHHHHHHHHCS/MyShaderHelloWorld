using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CommandBufferSamples : MonoBehaviour
{
	public static readonly int screenCopyID = Shader.PropertyToID("_ScreenCopyTex");
	public static readonly int blurCopyID = Shader.PropertyToID("_BlurCopyTex");


	public Shader blurGrassShader;
	private Material blurGrassMat;


	private void Start()
	{
		Init();
	}

	private void Init()
	{
		blurGrassMat = new Material(blurGrassShader);

		var camera = GetComponent<Camera>();

		CommandBuffer blurGrassCB = new CommandBuffer();
		blurGrassCB.name = "BlurGrass";

		int blurTex0ID = Shader.PropertyToID("_BlurTex_0");
		int blurTex1ID = Shader.PropertyToID("_BlurTex_1");
		int blurTex2ID = Shader.PropertyToID("_BlurTex_2");
		int blurTex3ID = Shader.PropertyToID("_BlurTex_3");

		blurGrassCB.GetTemporaryRT(blurTex0ID, 1920 >> 1, 1080 >> 1);
		blurGrassCB.GetTemporaryRT(blurTex1ID, 1920 >> 2, 1080 >> 2);
		blurGrassCB.GetTemporaryRT(blurTex2ID, 1920 >> 2, 1080 >> 2);
		blurGrassCB.GetTemporaryRT(blurTex3ID, 1920, 1080);

		blurGrassCB.Blit(BuiltinRenderTextureType.CurrentActive, blurTex3ID);
		//降采样
		blurGrassCB.Blit(blurTex3ID, blurTex0ID, blurGrassMat, 0);
		blurGrassCB.Blit(blurTex0ID, blurTex1ID, blurGrassMat, 0);
		//高斯模糊
		blurGrassCB.Blit(blurTex1ID, blurTex2ID, blurGrassMat, 2);
		blurGrassCB.Blit(blurTex2ID, blurTex1ID, blurGrassMat, 3);
		//升采样
		blurGrassCB.Blit(blurTex1ID, blurTex0ID, blurGrassMat, 1);
		blurGrassCB.Blit(blurTex0ID, blurTex3ID, blurGrassMat, 1);

		blurGrassCB.SetGlobalTexture(blurCopyID, blurTex3ID);

		camera.AddCommandBuffer(CameraEvent.AfterSkybox, blurGrassCB);
	}
}