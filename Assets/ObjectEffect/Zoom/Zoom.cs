using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Zoom : MonoBehaviour
{
	public Material mat = null;


	// 放大强度
	[Range(-2.0f, 2.0f), Tooltip("放大强度")] public float zoomFactor = 0.4f;

	// 放大镜大小
	[Range(0.0f, 0.2f), Tooltip("放大镜大小")] public float size = 0.15f;

	// 凸镜边缘强度
	[Range(0.0001f, 0.1f), Tooltip("凸镜边缘强度")]
	public float edgeFactor = 0.05f;

	// 遮罩中心位置
	private Vector2 pos = new Vector4(0.5f, 0.5f);

	private CommandBuffer cb;

	private void Awake()
	{
		InitCommandBuffer();

		Camera.main.AddCommandBuffer(CameraEvent.BeforeImageEffects, cb);
	}

	private void InitCommandBuffer()
	{
		cb = new CommandBuffer();

		cb = new CommandBuffer {name = "AfterEverything"};
		cb.BeginSample("MyCommandBuffer");

		int id = Shader.PropertyToID("CopyRT");
		cb.GetTemporaryRT(id, Screen.width, Screen.height, 0, FilterMode.Bilinear);

		//先把 CurrentActive 渲染出来 到id  不然是null 纯黑色
		cb.Blit(BuiltinRenderTextureType.CurrentActive, id);


		cb.Blit(id, BuiltinRenderTextureType.CameraTarget, mat);


		cb.ReleaseTemporaryRT(id);
		cb.EndSample("MyCommandBuffer");
	}

	private void Update()
	{
		if (Input.GetMouseButton(0))
		{
			Vector2 mousePos = Input.mousePosition;
			pos = new Vector2(mousePos.x / Screen.width, mousePos.y / Screen.height);
		}

		if (mat)
		{
			mat.SetVector("_Pos", pos);
			mat.SetFloat("_ZoomFactor", zoomFactor);
			mat.SetFloat("_EdgeFactor", edgeFactor);
			mat.SetFloat("_Size", size);

		}
	}
}