using System.Collections;
using System.Collections.Generic;
using UIEffect;
using UnityEngine;
using UnityEngine.UI;

public class UIHSVModifier : UIEffectBase
{
    public const string shaderName = "UI/UIEffectHSV";
    private static readonly ParameterTexture paramTex = new ParameterTexture(7, 128, "_ParamTex");

    [Header("要被替换的")]
    /// <summary>
    /// 要被替换的颜色/目标颜色
    /// </summary>
    [ColorUsage(false), SerializeField, Tooltip("要被替换的颜色/目标颜色")]
    private Color targetColor = Color.red;

    /// <summary>
    /// 颜色替换的范围
    /// </summary>
    [Range(0, 1f), SerializeField, Tooltip("颜色替换的范围")]
    private float range = 0.1f;


    [Header("替换后")]
    /// <summary>
    /// 替换后色调
    /// </summary>
    [Range(-0.5f, 0.5f), SerializeField, Tooltip("替换后色调")]
    private float hue;

    /// <summary>
    /// 替换后饱和度
    /// </summary>
    [Range(-0.5f, 0.5f), SerializeField, Tooltip("替换后饱和度")]
    private float saturation;

    /// <summary>
    /// 替换后明度/曝光度
    /// </summary>
    [Range(-0.5f, 0.5f), SerializeField, Tooltip("替换后明度/曝光度")]
    private float shiftValue;

    /// <summary>
    /// 参数图
    /// </summary>
    public override ParameterTexture ParamTex => paramTex;

    /// <summary>
    /// 要被替换的颜色/目标颜色
    /// </summary>
    public Color TargetColor
    {
        get => targetColor;
        set
        {
            if (targetColor != value)
            {
                targetColor = value;
                SetDirty();
            }
        }
    }

    /// <summary>
    /// 颜色替换的范围
    /// </summary>
    public float Range
    {
        get => range;
        set
        {
            if (range != value)
            {
                range = value;
                SetDirty();
            }
        }
    }

    /// <summary>
    /// 替换后色调
    /// </summary>
    public float Hue
    {
        get => hue;
        set
        {
            if (hue != value)
            {
                hue = value;
                SetDirty();
            }
        }
    }

    /// <summary>
    /// 替换后饱和度
    /// </summary>
    public float Saturation
    {
        get => saturation;
        set
        {
            if (saturation != value)
            {
                saturation = value;
                SetDirty();
            }
        }
    }

    /// <summary>
    /// 替换后明度/曝光度偏移
    /// </summary>
    public float ShiftValue
    {
        get => shiftValue;
        set
        {
            if (shiftValue != value)
            {
                shiftValue = value;
                SetDirty();
            }
        }
    }

    /// <summary>
    /// 修改图片顶点
    /// </summary>
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!isActiveAndEnabled)
        {
            return;
        }

        float normalizedIndex = ParamTex.GetNormalizedIndex(this);
        UIVertex vertex = default;
        for (int i = 0; i < vh.currentVertCount; i++)
        {
            vh.PopulateUIVertex(ref vertex, i);

            vertex.uv0 = new Vector2(
                Packer.ToFloat(vertex.uv0.x, vertex.uv0.y),
                normalizedIndex);

            vh.SetUIVertex(vertex, i);
        }
    }

    protected override void SetDirty()
    {
        //要被替换的颜色的RGB 转换 成色调,饱和度,曝光度
        float h, s, v;
        Color.RGBToHSV(targetColor, out h, out s, out v);

        ParamTex.RegisterMaterial(TargetGraphic.material);

        ParamTex.SetData(this, 0, h); //param1.x:要被替换的颜色的色调
        ParamTex.SetData(this, 1, s); //param1.y:要被替换的颜色的饱和度
        ParamTex.SetData(this, 2, v); //param1.z:要被替换的颜色的曝光度
        ParamTex.SetData(this, 3, range); //param1.w:要被替换的颜色的范围
        //加0.5转正,因为color不支持负数
        ParamTex.SetData(this, 4, hue + 0.5f); //param2.x:替换颜色的色调
        ParamTex.SetData(this, 5, saturation + 0.5f); //param2.y:替换颜色的饱和度
        ParamTex.SetData(this, 6, shiftValue + 0.5f); //param2.z:替换颜色的曝光度
    }

#if UNITY_EDITOR
    protected override Material GetMaterial()
    {
        return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName));
    }
#endif
}