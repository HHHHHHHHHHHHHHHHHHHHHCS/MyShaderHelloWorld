using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class TimeStopCtrl : MonoBehaviour
{
	public bool inputMousePos;

	public Shader effectShader;
	public Material effectMaterial;

	public float radiusTime = 3f;
	public float radiusDelta = 1f;
	public float impactRadiusTime = 3f;
	public float impactRadiusDelta = 0f;
	public float impactRadiusTime1 = 3f;
	public float impactRadiusDelta1 = 1.5f;
	public float sampleDistTime = 2f;
	public float sampleDistDelta = 0f;
	public float sampleStrengthTime = 2f;
	public float sampleStrengthDelta = 0f;

	private CommandBuffer cb;

	private Camera mainCam;
	private float startTime = -1f;

	private int step = 0;

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
		effectMaterial.SetFloat("_Radius", 0f);
		effectMaterial.SetFloat("_ImpactRadius", 0f);
		effectMaterial.SetFloat("_ImpactRadius1", 0f);
		effectMaterial.SetFloat("_SampleDist", 0f);
		effectMaterial.SetFloat("_SampleStrength", 0f);
		effectMaterial.SetFloat("_Gray", 0f);

	}

	private void InitCommandBuffer()
	{
		AudioSource ass;
		cb = new CommandBuffer {name = "AfterEverything"};
		cb.BeginSample("MyCommandBuffer");

		int id = Shader.PropertyToID("CopyRT");
		int id1 = Shader.PropertyToID("CopyRT1");
		cb.GetTemporaryRT(id, Screen.width, Screen.height, 0, FilterMode.Bilinear);
		cb.GetTemporaryRT(id1, Screen.width, Screen.height, 0, FilterMode.Bilinear);

		//先把 CurrentActive 渲染出来 到id  不然是null 纯黑色
		cb.Blit(BuiltinRenderTextureType.CurrentActive, id);
		cb.Blit(id, id1, effectMaterial, 0);
		cb.Blit(id1, BuiltinRenderTextureType.CameraTarget, effectMaterial, 1);

		cb.ReleaseTemporaryRT(id);
		cb.ReleaseTemporaryRT(id1);

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

		if (effectMaterial)
		{
			if (step == 0)
			{
				startTime = Time.time;
				step = 1;
			}

			if (step == 1)
			{
				if ((Time.time - startTime - sampleStrengthDelta) / sampleStrengthTime <= 1.0f)
				{
					effectMaterial.SetFloat("_Radius",
						Mathf.Lerp(0, 2, (Time.time - startTime - radiusDelta) / radiusTime));
					effectMaterial.SetFloat("_ImpactRadius",
						Mathf.Lerp(0, 2, (Time.time - startTime - impactRadiusDelta) / impactRadiusTime));
					effectMaterial.SetFloat("_ImpactRadius1",
						Mathf.Lerp(0, 2, (Time.time - startTime - impactRadiusDelta1) / impactRadiusTime1));
					if ((Time.time - startTime - impactRadiusDelta1) / impactRadiusTime1 >=0.5f)
					{
						effectMaterial.SetFloat("_SampleDist",
							Mathf.Lerp(0, 3f, (Time.time - startTime - sampleDistDelta) / sampleDistTime));
						effectMaterial.SetFloat("_SampleStrength",
							Mathf.Lerp(0, 6f, (Time.time - startTime - sampleStrengthDelta) / sampleStrengthTime));
					}
				}
				else
				{
					effectMaterial.SetFloat("_Gray", 1f);
					startTime = Time.time;
					step = 2;
				}
			}

			if (step == 2)
			{
				if ((Time.time - startTime - impactRadiusDelta1) / impactRadiusTime1 <= 1)
				{
					if ((Time.time - startTime ) / sampleStrengthTime >= 0.5f)
					{
						effectMaterial.SetFloat("_Radius",
							Mathf.Lerp(2, 0, (Time.time - startTime - radiusDelta) / radiusTime));
						effectMaterial.SetFloat("_ImpactRadius",
							Mathf.Lerp(2, 0, (Time.time - startTime - impactRadiusDelta) / impactRadiusTime));
						effectMaterial.SetFloat("_ImpactRadius1",
							Mathf.Lerp(2, 0, (Time.time - startTime - impactRadiusDelta1) / impactRadiusTime1));
					}
					effectMaterial.SetFloat("_SampleDist",
						Mathf.Lerp(3, 0, (Time.time - startTime ) / sampleDistTime));
					effectMaterial.SetFloat("_SampleStrength",
						Mathf.Lerp(6, 0, (Time.time - startTime ) / sampleStrengthTime));
				}
				else
				{
					step = 3;
				}
			}
		}
	}
}