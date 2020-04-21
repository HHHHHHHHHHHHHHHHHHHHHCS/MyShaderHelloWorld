using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AdvancedImageEX : Image
{
    [SerializeField] private bool m_visible = true;

    public bool Visible
    {
        get => m_visible;
        set
        {
            m_visible = value;
            UpdateVisible();
        }
    }

    protected override void OnEnable()
    {
        base.OnEnable();
        UpdateVisible();
    }

    #region 修正占用gcanvasRenderer.cull 属性 和Mask 产生的冲突

    private readonly Vector3[] m_corners = new Vector3[4];

    private Rect rootCanvasRect
    {
        get
        {
            //把rect 赋值给 m_corners
            rectTransform.GetWorldCorners(m_corners);

            if (canvas)
            {
                Canvas rootCanvas = canvas.rootCanvas;
                for (int i = 0; i < 4; ++i)
                {
                    m_corners[i] = rootCanvas.transform.InverseTransformPoint(m_corners[i]);
                }
            }

            return new Rect(m_corners[0].x, m_corners[0].y
                , m_corners[2].x - m_corners[0].x, m_corners[2].y - m_corners[0].y);
        }
    }

    private bool m_isCull;

    public override void Cull(Rect clipRect, bool validRect)
    {
        if (!canvasRenderer.hasMoved)
            return;

        var cull = !validRect || !clipRect.Overlaps(rootCanvasRect, true);
        var cullingChanged = m_isCull != cull;
        m_isCull = cull;

        UpdateVisible();

        if (cullingChanged)
        {
            onCullStateChanged.Invoke(cull);

            //SetVerticesDirty();
            //重新移回屏幕执行SetVerticesDirty会导致重建。
            //重建确实是必要的，因为在Mask外任何属性修改都不会导致ReBuild，移入后需要执行一次让界面更新。
            //但是，仅仅是移出Mask是不应该标记Vertices变动的，根本没变啊，所以换成下面这句。
            //这样仅仅是进出Mask就不会重建Mesh了。没看出有啥区别。
            //然而，Cull方法那里的SetDirty则直接是一个BUG了，
            //因为这次它隐藏的时候并没有清空CanvasRenderer，重建是一丁点意义都没有的行为，
            //用CanvasUpdateRegistry.RegisterCanvasElementForGraphicRebuild(this)代替才是正确的写法。
            if (IsActive())
                CanvasUpdateRegistry.RegisterCanvasElementForGraphicRebuild(this);
        }
    }

    public override void SetClipRect(Rect clipRect, bool validRect)
    {
        base.SetClipRect(clipRect, validRect);
        if (!validRect)
        {
            m_isCull = false; //移出Mask需要手动清除Cull标记
        }
    }

    public override void RecalculateClipping()
    {
        base.RecalculateClipping();
        UpdateVisible();
    }

    protected override void OnTransformParentChanged()
    {
        base.OnTransformParentChanged();
        if (!isActiveAndEnabled)
            return;

        UpdateVisible();
    }

    #endregion

    public void UpdateVisible()
    {
        canvasRenderer.cull = m_isCull || !m_visible;
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        UpdateVisible();
    }
#endif
}