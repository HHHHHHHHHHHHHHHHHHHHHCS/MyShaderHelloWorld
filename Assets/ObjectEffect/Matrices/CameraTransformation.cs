using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraTransformation : Transformation
{
    public enum MatrixEnum
    {
        Identity,
        Orthographic,
        Perspective,
    }

    public MatrixEnum _enum = MatrixEnum.Identity;
    public float focalLength = 1f;

    public override Matrix4x4 Matrix
    {
        get
        {
            Matrix4x4 mat;
            switch (_enum)
            {
                case MatrixEnum.Identity:
                    mat = Matrix0();
                    break;
                case MatrixEnum.Orthographic:
                    mat = Matrix1();
                    break;
                case MatrixEnum.Perspective:
                    mat = Matrix2();
                    break;
                default:
                    mat = Matrix0();
                    break;
            }
            return mat;
        }
    }

    /// <summary>
    /// Matrix4x4.identity
    /// </summary>
    private Matrix4x4 Matrix0()
    {
        //Matrix4x4.identity
        Matrix4x4 matrix = new Matrix4x4();
        matrix.SetRow(0, new Vector4(1f, 0f, 0f, 0f));
        matrix.SetRow(1, new Vector4(0f, 1f, 0f, 0f));
        matrix.SetRow(2, new Vector4(0f, 0f, 1f, 0f));
        matrix.SetRow(3, new Vector4(0f, 0f, 0f, 1f));
        return matrix;
    }

    /// <summary>
    /// Orthographic Camera
    /// </summary>
    private Matrix4x4 Matrix1()
    {
        Matrix4x4 matrix = new Matrix4x4();
        matrix.SetRow(0, new Vector4(1f, 0f, 0f, 0f));
        matrix.SetRow(1, new Vector4(0f, 1f, 0f, 0f));
        matrix.SetRow(2, new Vector4(0f, 0f, 0f, 0f));
        matrix.SetRow(3, new Vector4(0f, 0f, 0f, 1f));
        return matrix;
    }

    /// <summary>
    /// Perspective Camera
    /// </summary>
    /// <returns></returns>
    private Matrix4x4 Matrix2()
    {
        Matrix4x4 matrix = new Matrix4x4();
        matrix.SetRow(0, new Vector4(focalLength, 0f, 0f, 0f));
        matrix.SetRow(1, new Vector4(0f, focalLength, 0f, 0f));
        matrix.SetRow(2, new Vector4(0f, 0f, 0f, 0f));
        matrix.SetRow(3, new Vector4(0f, 0f, 1f, 0f));
        return matrix;
    }
}
