using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class TimeStopCtrl : MonoBehaviour
{
	public bool inputMousePos;
	public bool inputNoise;

	public Shader effectShader;
	public Material effectMaterial;

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
		AudioSource ass;
		cb = new CommandBuffer {name = "AfterEverything"};
		cb.BeginSample("MyCommandBuffer");

		int id = Shader.PropertyToID("CopyRT");
		cb.GetTemporaryRT(id, Screen.width, Screen.height, 0, FilterMode.Bilinear);

		//先把 CurrentActive 渲染出来 到id  不然是null 纯黑色
		cb.Blit(BuiltinRenderTextureType.CurrentActive, id);
		cb.Blit(id, BuiltinRenderTextureType.CameraTarget,effectMaterial);

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
	}
}