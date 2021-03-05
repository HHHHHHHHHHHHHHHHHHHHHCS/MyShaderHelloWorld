using System;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using Debug = UnityEngine.Debug;
using Random = System.Random;

namespace Noise.WorleyNoise3D
{
	public class WorleyNoise3D : MonoBehaviour
	{
		private const int computeThreadGroupSize = 8;

		private const int worley_Kernel = 0;
		private const int normalize_Kernel = 1;

		private static readonly int persistence_ID = Shader.PropertyToID("_Persistence");
		private static readonly int resolution_ID = Shader.PropertyToID("_Resolution");
		private static readonly int count_ID = Shader.PropertyToID("_Count");
		private static readonly int threadGroup_ID = Shader.PropertyToID("_ThreadGroup");
		private static readonly int minmax_ID = Shader.PropertyToID("_MinMax");
		private static readonly int result_ID = Shader.PropertyToID("_Result");


		private static readonly int pointsA_ID = Shader.PropertyToID("_PointsA");
		private static readonly int pointsB_ID = Shader.PropertyToID("_PointsB");
		private static readonly int pointsC_ID = Shader.PropertyToID("_PointsC");
		private static readonly int numCellsA_ID = Shader.PropertyToID("_NumCellsA");
		private static readonly int numCellsB_ID = Shader.PropertyToID("_NumCellsB");
		private static readonly int numCellsC_ID = Shader.PropertyToID("_NumCellsC");
		private static readonly int invertNoise_ID = Shader.PropertyToID("_InvertNoise");
		private static readonly int tile_ID = Shader.PropertyToID("_Tile");

		//--------------------
		public ComputeShader noiseCompute;
		public bool logComputeTime;

		//--------------------
		[Header("Noise Setting")] public int seed;
		[Range(1, 50)] public int numDivisionsA = 5;
		[Range(1, 50)] public int numDivisionsB = 10;
		[Range(1, 50)] public int numDivisionsC = 15;

		[Range(1, 128)] public int resolution = 64;
		public float persistence = .5f;
		public int tile = 1;
		public bool invert = true;


		//--------------------
		//这里不用RenderTexture(Texture3D) 而是用 ComputeBuffer<float>
		//想要实时的话 可以用RenderTexture(Texture3D) 
		//private RenderTexture noise3DTexture;
		private List<ComputeBuffer> buffersToRelease;
		private int count;

		private void Awake()
		{
			GeneratorNoise();
		}

		private void Init()
		{
			count = resolution * resolution * resolution;

			//CreateTexture(ref noise3DTexture, resolution, "WorleyNoise3D");

			if (buffersToRelease == null)
			{
				buffersToRelease = new List<ComputeBuffer>();
			}
			else
			{
				buffersToRelease.Clear();
			}
		}

		private void ReleaseCB()
		{
			//release buffers
			foreach (var buffer in buffersToRelease)
			{
				buffer.Release();
			}

			buffersToRelease.Clear();
		}


		public void GeneratorNoise()
		{
			Stopwatch timer = null;
			if (logComputeTime)
			{
				timer = Stopwatch.StartNew();
			}

			Init();

			ComputeBuffer resultCB = new ComputeBuffer(count, sizeof(float),
				ComputeBufferType.Default);

			//set values:
			noiseCompute.SetFloat(persistence_ID, persistence);
			noiseCompute.SetInt(resolution_ID, resolution);
			noiseCompute.SetInt(count_ID, count);


			//也可以用 noiseCompute.FindKernel("CSWorley");
			//noiseCompute.SetTexture(worley_Kernel, result_ID, noise3DTexture);
			noiseCompute.SetBuffer(worley_Kernel, result_ID, resultCB);
			var minMaxBuffer = CreateBuffer(new int[] {int.MaxValue, 0}, sizeof(int),
				minmax_ID, worley_Kernel);
			UpdateWorley();

			//dispatch noise gen kernel
			//也可以用 noiseCompute.GetKernelThreadGroupSizes(0, out uint x, out uint y, out uint z);
			int numThreadGroups = Mathf.CeilToInt(resolution / (float) computeThreadGroupSize);
			noiseCompute.SetInt(threadGroup_ID, numThreadGroups);
			noiseCompute.Dispatch(worley_Kernel, numThreadGroups, numThreadGroups, numThreadGroups);

			// var results = new float[count];
			// resultCB.GetData(results);
			// int zz = 0;
			// for (int i = 0; i < count; i++)
			// {
			// 	var res = results[i];
			// 	Debug.Log(res);
			// }

			//set normalization  
			noiseCompute.SetBuffer(normalize_Kernel, minmax_ID, minMaxBuffer);
			noiseCompute.SetBuffer(normalize_Kernel, result_ID, resultCB);
			//noiseCompute.SetTexture(normalize_Kernel, result_ID, noise3DTexture);
			//dispatch normalization
			noiseCompute.Dispatch(normalize_Kernel, numThreadGroups, numThreadGroups, numThreadGroups);


#if UNITY_EDITOR
			SaveAsset(resultCB);
#endif


			resultCB.Dispose();
			ReleaseCB();

			if (logComputeTime)
			{
				Debug.Log($"Noise Generation: {timer.ElapsedMilliseconds} ms");
			}
		}

#if UNITY_EDITOR
		private void SaveAsset(ComputeBuffer resultCB)
		{
			Texture3D asset = new Texture3D(resolution, resolution, resolution, TextureFormat.RFloat, false);
			var results = new float[count];
			var colors = new Color[count];

			resultCB.GetData(results);
			for (int i = 0; i < count; i++)
			{
				var res = results[i];
				colors[i] = new Color(res, res, res, res);
				// Debug.Log(res);
			}

			asset.SetPixels(colors);
			UnityEditor.AssetDatabase.CreateAsset(asset, "Assets/Noise/WorleyNoise3D/" + "WorleyNoise3D" + ".asset");
			UnityEditor.AssetDatabase.Refresh();
		}
#endif


		private void CreateTexture(ref RenderTexture texture, int resolution, string textureName)
		{
			var format = GraphicsFormat.R16G16B16A16_UNorm;
			if (texture == null || !texture.IsCreated() || texture.width != resolution ||
			    texture.height != resolution || texture.volumeDepth != resolution || texture.graphicsFormat != format)
			{
				//Debug.Log ("Create tex: update noise: " + updateNoise);
				if (texture != null)
				{
					texture.Release();
				}

				texture = new RenderTexture(resolution, resolution, 0, format, 0)
				{
					name = textureName,
					volumeDepth = resolution,
					enableRandomWrite = true,
					dimension = TextureDimension.Tex3D,
					wrapMode = TextureWrapMode.Repeat,
					filterMode = FilterMode.Bilinear,
				};
				texture.Create();
			}
		}

		private ComputeBuffer CreateBuffer(Array data, int stride, int bufferName, int kernel = 0)
		{
			var buffer = new ComputeBuffer(data.Length, stride, ComputeBufferType.Structured);
			buffersToRelease.Add(buffer);
			buffer.SetData(data);
			noiseCompute.SetBuffer(kernel, bufferName, buffer);
			return buffer;
		}

		private void CreateWorleyPointsBuffer(Random prng, int numCellsPerAxis, int bufferName)
		{
			var points = new Vector3[numCellsPerAxis * numCellsPerAxis * numCellsPerAxis];
			float cellSize = 1f / numCellsPerAxis;

			for (int x = 0; x < numCellsPerAxis; x++)
			{
				for (int y = 0; y < numCellsPerAxis; y++)
				{
					for (int z = 0; z < numCellsPerAxis; z++)
					{
						float randomX = (float) prng.NextDouble(); //return 0~1
						float randomY = (float) prng.NextDouble();
						float randomZ = (float) prng.NextDouble();
						Vector3 randomOffset = new Vector3(randomX, randomY, randomZ) * cellSize;
						//逐渐增长
						Vector3 cellCorner = new Vector3(x, y, z) * cellSize;

						int index = x + numCellsPerAxis * (y + z * numCellsPerAxis);
						points[index] = cellCorner + randomOffset;
					}
				}
			}

			CreateBuffer(points, sizeof(float) * 3, bufferName, worley_Kernel);
		}

		private void UpdateWorley()
		{
			var prng = new Random(seed);
			CreateWorleyPointsBuffer(prng, numDivisionsA, pointsA_ID);
			CreateWorleyPointsBuffer(prng, numDivisionsB, pointsB_ID);
			CreateWorleyPointsBuffer(prng, numDivisionsC, pointsC_ID);

			noiseCompute.SetInt(numCellsA_ID, numDivisionsA);
			noiseCompute.SetInt(numCellsB_ID, numDivisionsB);
			noiseCompute.SetInt(numCellsC_ID, numDivisionsC);
			noiseCompute.SetBool(invertNoise_ID, invert);
			noiseCompute.SetInt(tile_ID, tile);
		}
	}
}