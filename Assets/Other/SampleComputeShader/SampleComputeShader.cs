using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SampleComputeShader : MonoBehaviour
{
    public ComputeShader calcMeshShader;

    private ComputeBuffer preBuffer;
    private ComputeBuffer nextBuffer;
    private ComputeBuffer resultBuffer;

    public Vector3[] array1;
    public Vector3[] array2;
    public Vector3[] resultArr;

    public int length = 16;

    private int kernel;

    private void Start()
    {
        array1 = new Vector3[length];
        array2 = new Vector3[length];
        resultArr = new Vector3[length];

        for (int i = 0; i < length; i++)
        {
            array1[i] = Vector3.one;
            array2[i] = Vector3.one * 2;
        }

        InitBuffers();


        kernel = calcMeshShader.FindKernel("CSMain");

        calcMeshShader.SetBuffer(kernel, "preVertices", preBuffer);

        calcMeshShader.SetBuffer(kernel, "nextVertices", nextBuffer);

        calcMeshShader.SetBuffer(kernel, "Result", resultBuffer);

    }

    private void InitBuffers()
    {
        //缓冲区中一个元素的大小。必须匹配着色器中缓冲区类型的大小。
        //vector3 3float = 3*4
        preBuffer = new ComputeBuffer(array1.Length,12);
        preBuffer.SetData(array1);

        nextBuffer = new ComputeBuffer(array2.Length, 12);
        nextBuffer.SetData(array2);

        resultBuffer = new ComputeBuffer(resultArr.Length, 12);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            //传入线程组
            calcMeshShader.Dispatch(kernel,2,2,1);
            resultBuffer.GetData(resultArr);

            resultBuffer.Release();
        }
    }


    private void OnDestroy()
    {
        
        preBuffer.Release();
        nextBuffer.Release();
    }
}
