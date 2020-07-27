using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class SimpleLensFlare : MonoBehaviour
{
	[System.Serializable]
	public class FlareSettings
	{
		public float rayPosition;
		public Material material;
		[ColorUsage(true, true)] public Color color;
		public bool multiplyByLightColor;
		public Vector2 size;
		public float rotation;
		public bool autoRotate;

		public FlareSettings()
		{
			rayPosition = 0.0f;
			color = Color.white;
			multiplyByLightColor = true;
			size = new Vector2(0.3f, 0.3f);
			rotation = 0.0f;
			autoRotate = true;
		}
	}

	private const string shaderName = "ScreenEffect/S_SimpleLensFlare";

	[SerializeField] private Light light;

	private MeshRenderer meshRenderer;
	private MeshFilter meshFilter;

	[Header("Global Settings")] public float occlusionRadius = 1.0f;
	public float nearFadeStartDistance = 1.0f;
	public float nearFadeEndDistance = 3.0f;
	public float farFadeStartDistance = 10.0f;
	public float farFadeEndDistance = 50.0f;

	[Header("Flare Element Settings")] [SerializeField]
	public List<FlareSettings> flares;

	private bool isInit = false;

	private void Awake()
	{
		Init();
	}

	private void OnEnable()
	{
		UpdateGeometry();
	}

	private void OnValidate()
	{
		Init();
		UpdateGeometry();
		UpdateMaterials();
	}

	private void Update()
	{
		// 偷懒的做法
		UpdateVaryingAttributes();
	}

	private void Init()
	{
		if (isInit)
		{
			return;
		}

		isInit = true;

		Camera.main.depthTextureMode |= DepthTextureMode.Depth;

		if (meshFilter == null)
		{
			meshFilter = GetComponent<MeshFilter>();
		}

		if (meshRenderer == null)
		{
			meshRenderer = GetComponent<MeshRenderer>();
		}

		if (light == null)
		{
			light = GetComponent<Light>();
		}

		//C# 8.0 引入了 null 合并赋值运算符 ??=。 仅当左操作数计算为 null 时，才能使用运算符 ??= 将其右操作数的值分配给左操作数。
		//但是 mono 的东西不好这样操作  因为unity 的东西 == null 会有一定的转换
		//flares ??= new List<FlareSettings>();
		if (flares == null)
		{
			flares = new List<FlareSettings>();
		}

		meshFilter.mesh = InitMesh();
	}

	private Mesh InitMesh()
	{
		Mesh m = new Mesh();
		//优化频繁更新的网格，分配顶点之前调用这个，当连续更新网格时，以获得更好的性能。
		// 内部将使网格在底层图形接口使用“动态缓存器”，当网格数据经常改变时，更高效。
		m.MarkDynamic();
		return m;
	}

	void UpdateMaterials()
	{
		Material[] mats = new Material[flares.Count];

		int i = 0;
		foreach (FlareSettings f in flares)
		{
			if (f.material == null)
			{
				//偷懒的做法  没有 destroy
				f.material = new Material(Shader.Find(shaderName))
				{
					name = i.ToString(), hideFlags = HideFlags.DontSave,
				};
			}

			mats[i] = f.material;
			i++;
		}

		meshRenderer.sharedMaterials = mats;
	}

	private void UpdateGeometry()
	{
		Mesh m = meshFilter.sharedMesh;

		List<Vector3> vertices = new List<Vector3>();
		foreach (var item in flares)
		{
			vertices.Add(new Vector3(-1, -1, 0));
			vertices.Add(new Vector3(1, -1, 0));
			vertices.Add(new Vector3(1, 1, 0));
			vertices.Add(new Vector3(-1, 1, 0));
		}

		m.SetVertices(vertices);

		List<Vector2> uvs = new List<Vector2>();
		foreach (var item in flares)
		{
			uvs.Add(new Vector2(0, 1));
			uvs.Add(new Vector2(1, 1));
			uvs.Add(new Vector2(1, 0));
			uvs.Add(new Vector2(0, 0));
		}

		m.SetUVs(0, uvs);


		//https://forum.unity.com/threads/what-is-a-difference-between-mesh-uv-and-mesh-setuvs.451257/
		// Variable Data
		m.SetColors(GetLensFlareColor());
		m.SetUVs(1, GetLensFlareData());
		m.SetUVs(2, GetWorldPositionAndRadius());
		m.SetUVs(3, GetDistanceFadeData());

		m.subMeshCount = flares.Count;

		// Tris
		for (int i = 0; i < flares.Count; i++)
		{
			int[] tris = new int[6];
			tris[0] = (i * 4) + 0;
			tris[1] = (i * 4) + 1;
			tris[2] = (i * 4) + 2;
			tris[3] = (i * 4) + 2;
			tris[4] = (i * 4) + 3;
			tris[5] = (i * 4) + 0;
			m.SetTriangles(tris, i);
		}

		//更新AABB 和 尺寸
		Bounds b = m.bounds;
		b.extents = new Vector3(occlusionRadius, occlusionRadius, occlusionRadius);
		m.bounds = b;
		m.UploadMeshData(false);
		m.name = "LensFlare (" + gameObject.name + ")";
	}

	private void UpdateVaryingAttributes()
	{
		Mesh m = meshFilter.sharedMesh;

		//存储lensflare相关参数
		var x = GetLensFlareColor();
		m.SetColors(x);
		var y = GetLensFlareData();
		m.SetUVs(1, y);
		var z = GetWorldPositionAndRadius();
		m.SetUVs(2, z);
		var w = GetDistanceFadeData();
		m.SetUVs(3, w);

		Bounds b = m.bounds;
		b.extents = new Vector3(occlusionRadius, occlusionRadius, occlusionRadius);
		m.bounds = b;
		m.name = "LensFlare (" + gameObject.name + ")";
	}

	private List<Color> GetLensFlareColor()
	{
		List<Color> colors = new List<Color>();
		foreach (var item in flares)
		{
			Color c = (item.multiplyByLightColor && light != null)
				? item.color * light.color * light.intensity
				: item.color;

			colors.Add(c);
			colors.Add(c);
			colors.Add(c);
			colors.Add(c);
		}

		return colors;
	}

	private List<Vector4> GetLensFlareData()
	{
		List<Vector4> lfData = new List<Vector4>();

		foreach (var item in flares)
		{
			var data = new Vector4(item.rayPosition, item.autoRotate ? -1 : Mathf.Abs(item.rotation), item.size.x,
				item.size.y);
			lfData.Add(data);
			lfData.Add(data);
			lfData.Add(data);
			lfData.Add(data);
		}

		return lfData;
	}


	private List<Vector4> GetWorldPositionAndRadius()
	{
		List<Vector4> worldPos = new List<Vector4>();
		Vector3 pos = transform.position;
		Vector4 value = new Vector4(pos.x, pos.y, pos.z, occlusionRadius);
		foreach (var item in flares)
		{
			worldPos.Add(value);
			worldPos.Add(value);
			worldPos.Add(value);
			worldPos.Add(value);
		}

		return worldPos;
	}

	private List<Vector4> GetDistanceFadeData()
	{
		List<Vector4> fadeData = new List<Vector4>();

		foreach (var item in flares)
		{
			var data = new Vector4(nearFadeStartDistance, nearFadeEndDistance, farFadeStartDistance,
				farFadeEndDistance);
			fadeData.Add(data);
			fadeData.Add(data);
			fadeData.Add(data);
			fadeData.Add(data);
		}

		return fadeData;
	}
}