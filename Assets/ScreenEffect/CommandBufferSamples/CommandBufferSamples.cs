using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CommandBufferSamples : MonoBehaviour
{
	public static readonly int screenCopyID = Shader.PropertyToID("_ScreenCopyTex");
	public static readonly int blurCopyID = Shader.PropertyToID("_BlurCopyTex");
	public static readonly int outlineCopyID = Shader.PropertyToID("_OutlineCopyTex");


	public Shader objOutlineShader;
	public Shader blurGrassShader;
	public Shader objBlurGlassShader;
	public Shader uberShader;

	public Renderer[] outlineRenderers;
	public Renderer[] blurRenderers;

	private Material objOutlineMat;
	private Material blurGrassMat;
	private Material objBlurGlassMat;
	private Material uberMat;

	private RenderTexture outlineRT, blurRT;


	private void Start()
	{
		Init();
	}

	private void Init()
	{
		objOutlineMat = new Material(objOutlineShader);
		blurGrassMat = new Material(blurGrassShader);
		objBlurGlassMat = new Material(objBlurGlassShader);
		uberMat = new Material(uberShader);


		var camera = GetComponent<Camera>();

		//outline
		//---------------------
		CommandBuffer outlineCB = new CommandBuffer();
		outlineCB.name = "Outline";

		outlineRT = new RenderTexture(1920, 1080, 0, RenderTextureFormat.ARGB32);
		outlineRT.name = "outlineRT";
		outlineCB.SetRenderTarget(outlineRT);
		outlineCB.ClearRenderTarget(true, true, Color.clear);

		if (outlineRenderers != null && outlineRenderers.Length > 0)
		{
			foreach (var item in outlineRenderers)
			{
				outlineCB.DrawRenderer(item, objOutlineMat);
			}
		}

		camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, outlineCB);


		//blurGrass
		//---------------------
		CommandBuffer blurGrassCB = new CommandBuffer();
		blurGrassCB.name = "BlurGrass";

		blurRT = new RenderTexture(1920, 1080, 0, RenderTextureFormat.ARGB32);
		blurRT.name = "blurRT";
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

		blurGrassCB.SetGlobalTexture("_BlurTempTex", blurTex3ID);

		blurGrassCB.SetRenderTarget(blurRT);
		blurGrassCB.ClearRenderTarget(true, true, Color.clear);
		if (blurRenderers != null && blurRenderers.Length > 0)
		{
			foreach (var item in blurRenderers)
			{
				item.enabled = false;
				blurGrassCB.DrawRenderer(item, objBlurGlassMat);
			}
		}

		camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, blurGrassCB);

		//uber
		//---------------------
		CommandBuffer uberCB = new CommandBuffer();
		uberCB.name = "Uber";
		uberCB.Blit(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CurrentActive, uberMat);
		uberCB.SetGlobalTexture(outlineCopyID, outlineRT);
		uberCB.SetGlobalTexture(blurCopyID, blurRT);
		camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, uberCB);
	}
}