using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class ImageEffectCommandBuffer : MonoBehaviour
{
	public bool inputMousePos;
	public bool inputNoise;

	public Shader effectShader;
	public Material effectMaterial;

	public bool renderFirstPass = false;

	public Texture2D noise;

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
		mainCam.AddCommandBuffer(CameraEvent.BeforeImageEffects, cb);

		effectMaterial.SetVector("_MousePos", new Vector2(0.5f, 0.5f));
		effectMaterial.SetTexture("_Noise", Texture2D.grayTexture);
	}

	private void InitCommandBuffer()
	{
		cb = new CommandBuffer {name = "AfterEverything"};
		cb.BeginSample("MyCommandBuffer");

		int id = Shader.PropertyToID("CopyRT");
		cb.GetTemporaryRT(id, Screen.width, Screen.height, 0, FilterMode.Bilinear);

		//先把 CurrentActive 渲染出来 到id  不然是null 纯黑色
		cb.Blit(BuiltinRenderTextureType.CurrentActive, id);

		int count = effectMaterial.passCount;

		if (renderFirstPass || count == 1)
		{
			cb.Blit(id, BuiltinRenderTextureType.CameraTarget, effectMaterial);
		}
		else
		{
			int id1 = Shader.PropertyToID("CopyRT1");
			cb.GetTemporaryRT(id1, Screen.width, Screen.height, 0, FilterMode.Bilinear);

			for (int i = 0; i < count; ++i)
			{
				if (i == count - 1)
				{
					cb.Blit(i % 2 == 0 ? id : id1, BuiltinRenderTextureType.CameraTarget, effectMaterial, i);
				}
				else
				{
					cb.Blit(i % 2 == 0 ? id : id1, i % 2 == 1 ? id : id1, effectMaterial, i);
				}
			}
			
			cb.ReleaseTemporaryRT(id);
		}


		cb.ReleaseTemporaryRT(id);
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
				viewPos.x = Mathf.Clamp01(viewPos.x);
				viewPos.y = Mathf.Clamp01(viewPos.y);
				//Debug.Log($"({viewPos.x:F5}, {viewPos.y:F5})");
				effectMaterial.SetVector("_MousePos", viewPos);
			}
		}

		if (inputNoise && effectMaterial && noise)
		{
			effectMaterial.SetTexture("_Noise", noise);
		}
	}
}