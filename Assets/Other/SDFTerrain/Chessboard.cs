using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chessboard : MonoBehaviour
{
	[Header("棋盘格大小")] public int cellSize = 20;

	#region Instance

	public static Chessboard Instance = null;

	private void Awake()
	{
		Instance = this;
		lastChessPosition = new Vector2Int(-9999, -9999);
	}

	private void OnDestroy()
	{
		Instance = null;
	}

	#endregion

	#region Dictionary

	private Dictionary<int, Dictionary<int, List<Chess>>>
		xzToChess = new Dictionary<int, Dictionary<int, List<Chess>>>();

	private List<Chess> result = new List<Chess>();

	public void RemoveMember(Chess mf)
	{
		result.Clear();
		Vector3 v = mf.transform.position;
		int x = Mathf.FloorToInt(v.x / cellSize);
		int z = Mathf.FloorToInt(v.z / cellSize);

		var isFind = xzToChess.TryGetValue(x, out var row);
		if (!isFind)
		{
			row = new Dictionary<int, List<Chess>>();
			xzToChess.Add(x, row);
		}

		isFind = row.TryGetValue(z, out var cell);
		if (!isFind)
		{
			cell = new List<Chess>();
			row.Add(z, cell);
		}

		cell.Remove(mf);
	}

	public void AddMember(Chess mf)
	{
		Vector3 v = mf.transform.position;
		int x = Mathf.FloorToInt(v.x / cellSize);
		int z = Mathf.FloorToInt(v.z / cellSize);

		var isFind = xzToChess.TryGetValue(x, out var row);
		if (!isFind)
		{
			row = new Dictionary<int, List<Chess>>();
			xzToChess.Add(x, row);
		}

		isFind = row.TryGetValue(z, out var cell);
		if (!isFind)
		{
			cell = new List<Chess>();
			row.Add(z, cell);
		}

		cell.Add(mf);
	}

	public List<Chess> GetMember(int x, int z)
	{
		var isFind = xzToChess.TryGetValue(x, out var row);
		if (!isFind)
		{
			return null;
		}

		isFind = row.TryGetValue(z, out var cell);
		if (!isFind)
		{
			return null;
		}

		return cell;
	}

	public List<Chess> GetMembers(int x, int z, int rad = 0)
	{
		result.Clear();
		if (rad <= 0)
		{
			return result;
		}

		for (int i = x - rad; i <= x + rad; i++)
		{
			for (int j = z - rad; j < z + rad; j++)
			{
				var r = GetMember(i, j);
				if (r != null)
				{
					result.AddRange(r);
				}
			}
		}

		return result;
	}

	#endregion

	#region Update

	public Transform playerTrans;
	private Vector2Int lastChessPosition;

	private void FixedUpdate()
	{
		if (playerTrans == null)
		{
			return;
		}

		Vector3 v = playerTrans.position;
		int x = Mathf.FloorToInt(v.x / cellSize);
		int z = Mathf.FloorToInt(v.z / cellSize);
		if (lastChessPosition.x == x && lastChessPosition.y == z)
		{
			return;
		}

		lastChessPosition = new Vector2Int(x, z);
		OnChessPositionChanged();
	}

	#endregion


	#region Bake

	private const int VLIMIT = 1048576;
	private const int TLIMIT = 4194304;

	public enum BakeType
	{
		Texture3D = 0,
		PointCloud = 1,
	}

	[Header("Baker_Texture3D.compute")] public ComputeShader baker;
	[Header("烘焙类型")] public BakeType bakeType;
	[Header("地形材质")] public Material terrainMat;
	private List<Vector4> vertices = new List<Vector4>(VLIMIT);

	private void OnChessPositionChanged()
	{
		Debug.Log(string.Format("Player position changed to {0} now, start new bake SDF", lastChessPosition));
		if (baker == null)
			return;
		if (bakeType == BakeType.Texture3D)
			BakeTexture3D(1, cellSize, playerTrans.position);
	}

	private ComputeBuffer cbv, cbt;

	private void BakeTexture3D(int rad, int cellSize, Vector3 position)
	{
		//Texture3D在世界空间下的范围
		int textureWidthInWorldSpace = (1 + rad * 2) * cellSize;
		var center = new Vector4(lastChessPosition.x * cellSize,
			0, lastChessPosition.y * cellSize, 0);

		int kernelID_0 = baker.FindKernel("BakeToTexture_Empty");
		int kernelID_1 = baker.FindKernel("BakeToTexture");

		if (cbt == null)
		{
			List<float> sdf = new List<float>(TLIMIT);
			for (int i = 0; i < TLIMIT; i++)
			{
				sdf.Add(0);
			}

			cbt = new ComputeBuffer(TLIMIT, sizeof(float));
			cbt.SetData(sdf);
			baker.SetBuffer(kernelID_0, "Result", cbt);
			baker.SetBuffer(kernelID_1, "Result", cbt);
		}

		//清理SDF内的数据
		baker.Dispatch(kernelID_0, 256 / 16, 256 / 16, 64 / 4);


		//逐个object传递顶点和矩阵
		if (cbv == null)
		{
			cbv = new ComputeBuffer(VLIMIT, sizeof(float) * 4);
		}

		baker.SetVector("PlayerStand", center);
		baker.SetFloat("TextureWidthInWorldSpace", textureWidthInWorldSpace);
		vertices.Clear();
		var chesses = GetMembers(lastChessPosition.x, lastChessPosition.y, 1);
		foreach (var chess in chesses)
		{
			if (chess.mf == null || chess.mf.mesh == null)
			{
				continue;
			}

			int num = 0;

			foreach (var v in chess.mf.mesh.vertices)
			{
				if (num < VLIMIT)
				{
					vertices.Add(new Vector4(v.x, v.y, v.z, chess.force));
					num++;
				}
				else
				{
					// Debug.Log("vertices count > " + VLIMIT);
				}
			}

			cbv.SetData<Vector4>(vertices);
			baker.SetMatrix("ObjectToWorldMatrix", chess.transform.localToWorldMatrix);
			baker.SetBuffer(kernelID_1, "Vertices", cbv);
			baker.Dispatch(kernelID_1, 256 / 16, 256 / 16, 64 / 4);
		}

		if (terrainMat)
		{
			terrainMat.SetVector("PlayerStand", center);
			terrainMat.SetFloat("TextureWidthInWorldSpace", textureWidthInWorldSpace);
			terrainMat.SetBuffer("Result", cbt);
		}
	}

	#endregion
}