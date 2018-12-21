using UnityEngine;

namespace UIEffect
{
    /// <summary>
    /// 压缩xyzw为一个float
    /// 用 24 是 因为 是4 3 2 的倍数
    /// </summary>
    public sealed class Packer
    {
    /// <summary>
    /// 把4个 0-1 封装成float
    /// 每一个精度位6位(64)
    /// </summary>
    public static float ToFloat(float x, float y, float z, float w)
    {
    const int PRECISION = (1 << 6) - 1;

    x = Mathf.Clamp01(x);
    y = Mathf.Clamp01(y);
    z = Mathf.Clamp01(z);
    w = Mathf.Clamp01(w);

    return (Mathf.FloorToInt(w * PRECISION) << 18)
       + (Mathf.FloorToInt(z * PRECISION) << 12)
       + (Mathf.FloorToInt(y * PRECISION) << 6)
       + Mathf.FloorToInt(x * PRECISION);
    }

    /// <summary>
    /// 同<see cref="UIEffect.Packer.ToFloat(float,float,float,float)" />一样
    /// </summary>
    public static float ToFloat(Vector4 v4)
    {
    return ToFloat(v4.x, v4.y, v4.z, v4.w);
    }

    /// <summary>
    /// 把3个 0-1 封装成float
    /// x,y,z最大为8位(255)
    /// </summary>
    public static float ToFloat(float x, float y, float z)
    {
    const int PRECISION = (1 << 8) - 1;
    x = Mathf.Clamp01(x);
    y = Mathf.Clamp01(y);
    z = Mathf.Clamp01(z);

    return (Mathf.FloorToInt(z * PRECISION) << 16)
       + (Mathf.FloorToInt(y * PRECISION) << 8)
       + Mathf.FloorToInt(x * PRECISION);
    }

    /// <summary>
    /// 同<see cref="UIEffect.Packer.ToFloat(float,float,float)" />一样
    /// </summary>
    public static float ToFloat(Vector3 v3)
    {
    return ToFloat(v3.x, v3.y, v3.z);
    }

    /// <summary>
    /// 把2个 0-1 封装成float
    /// x,y最大为12位(4096)
    /// </summary>
    public static float ToFloat(float x, float y)
    {
    const int PRECISION = (1 << 12) - 1;
    x = Mathf.Clamp01(x);
    y = Mathf.Clamp01(y);
    return (Mathf.FloorToInt(y * PRECISION) << 12)
       + Mathf.FloorToInt(x * PRECISION);
    }

    /// <summary>
    /// 同<see cref="UIEffect.Packer.ToFloat(float,float)" />一样
    /// </summary>
    public static float ToFloat(Vector2 v2)
    {
    return ToFloat(v2.x, v2.y);
    }
    }
}