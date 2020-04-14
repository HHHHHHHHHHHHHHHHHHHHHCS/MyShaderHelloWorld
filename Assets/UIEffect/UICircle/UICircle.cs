using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Sprites;
using UnityEngine.UI;

[ExecuteInEditMode]
public class UICircle : CircleImage
{
    [SerializeField, Range(5, 20), Tooltip("弧形顶点个数")]
    private int scSegments = 9;

    public int SemiSegments
    {
        set
        {
            if (scSegments != value)
            {
                scSegments = value;
                SetVerticesDirty();
            }
        }

        get => scSegments;
    }

    [SerializeField, Tooltip("是否围绕StartAngle旋转")]
    private bool surround = false;

    public bool Surround
    {
        set
        {
            if (surround != value)
            {
                surround = value;
                SetVerticesDirty();
            }
        }

        get => surround;
    }

    [SerializeField, Range(-360, 360), Tooltip("设置进度条起始点位置")]
    private int startAngle = 0;

    public int StartAngle
    {
        set
        {
            if (startAngle != value)
            {
                startAngle = value;
                SetVerticesDirty();
            }
        }

        get => startAngle;
    }

    [SerializeField, Range(0, 1), Tooltip("当前进度")]
    private float percentage = 0;

    public float Percentage
    {
        set
        {
            if (percentage != value)
            {
                percentage = Mathf.Clamp(value, minPercentage, maxPercentage);
                SetVerticesDirty();
            }
        }
        get => percentage;
    }

    [SerializeField, Range(0, 1), Tooltip("最小值")]
    private float minPercentage = 0;

    private float MinPercentage
    {
        set
        {
            minPercentage = value;
            Percentage = Mathf.Clamp(percentage, minPercentage, maxPercentage);
        }
        get => minPercentage;
    }

    [SerializeField, Range(0, 1), Tooltip("最大值")]
    private float maxPercentage = 1;

    private float MaxPercentage
    {
        set
        {
            maxPercentage = value;
            Percentage = Mathf.Clamp(percentage, minPercentage, maxPercentage);
        }
        get => minPercentage;
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        //修正percentage
        percentage = Mathf.Clamp(percentage, minPercentage, maxPercentage);
        //clear old vertex data
        vh.Clear();
        innerVertices.Clear();
        outterVertices.Clear();
        //结束角度
        float endDegree = (2 * Mathf.PI) * percentage;
        //判断是否环绕某个角度
        float startDegree = startAngle * Mathf.Deg2Rad;
        if (surround)
        {
            startDegree = startDegree - endDegree * 0.5f;
        }

        float degreeDelta = (float) (2 * Mathf.PI / segements);
        int curSegements = Mathf.CeilToInt(endDegree / degreeDelta);

        float tw = rectTransform.rect.width;
        float th = rectTransform.rect.height;
        float outerRadius = rectTransform.pivot.x * tw;
        float innerRadius = rectTransform.pivot.x * tw - thickness;

        Vector4 uv = overrideSprite != null ? DataUtility.GetOuterUV(overrideSprite) : Vector4.zero;

        float uvCenterX = (uv.x + uv.z) * 0.5f;
        float uvCenterY = (uv.y + uv.w) * 0.5f;
        float uvScaleX = (uv.z - uv.x) / tw;
        float uvScaleY = (uv.w - uv.y) / th;

        float curDegree = 0;
        UIVertex uiVertex;
        int verticeCount;
        int triangleCount;
        Vector2 curVertice;

        verticeCount = curSegements * 2;
        for (int i = 0; i < verticeCount; i += 2)
        {
            float cosA = Mathf.Cos(curDegree + startDegree);
            float sinA = Mathf.Sin(curDegree + startDegree);
            curDegree = Mathf.Min(endDegree, curDegree + degreeDelta);
            /// 内环点
            curVertice = new Vector3(cosA * innerRadius, sinA * innerRadius);
            uiVertex = new UIVertex();
            uiVertex.color = color;
            uiVertex.position = curVertice;
            uiVertex.uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY);
            vh.AddVert(uiVertex);
            innerVertices.Add(curVertice);
            /// 外环点
            curVertice = new Vector3(cosA * outerRadius, sinA * outerRadius);
            uiVertex = new UIVertex();
            uiVertex.color = color;
            uiVertex.position = curVertice;
            uiVertex.uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY);
            vh.AddVert(uiVertex);
            outterVertices.Add(curVertice);
        }

        // 三角形个数
        triangleCount = curSegements * 3 * 2;
        for (int i = 0, vIdx = 0; i < triangleCount - 6; i += 6, vIdx += 2)
        {
            vh.AddTriangle(vIdx + 1, vIdx, vIdx + 3);
            vh.AddTriangle(vIdx, vIdx + 2, vIdx + 3);
        }

        if (percentage == 1)
        {
            //首尾顶点相连
            vh.AddTriangle(verticeCount - 1, verticeCount - 2, 1);
            vh.AddTriangle(verticeCount - 2, 0, 1);
        }
        else if (verticeCount > 0)
        {
            //做两头的半圆处理
            var thickRadius = outerRadius - thickness * 0.5f;
            float head_mid_x = thickRadius * Mathf.Cos(startDegree); float head_mid_y = thickRadius * Mathf.Sin(startDegree);
            float trial_mid_x = thickRadius * Mathf.Cos(curDegree + startDegree); float trial_mid_y = thickRadius * Mathf.Sin(curDegree + startDegree);
            float step = 180 / (scSegments + 1) * Mathf.Deg2Rad;
            float cur_radius = thickness * 0.5f;
            int head_trangle_idx = 1; int tt_startidx = verticeCount - 2; int tt_endidx = verticeCount - 1;
            for (int i = 0; i < scSegments; i++)
            {
                float degree = (step + step * i);
                /// 加头部半圆
                curVertice = new Vector3(Mathf.Cos(startDegree - degree) * cur_radius + head_mid_x, Mathf.Sin(startDegree - degree) * cur_radius + head_mid_y);
                uiVertex = new UIVertex();
                uiVertex.color = color;
                uiVertex.position = curVertice;
                uiVertex.uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY);
                vh.AddVert(uiVertex);
                // 添加一个三角形
                vh.AddTriangle(0, head_trangle_idx, verticeCount);
                head_trangle_idx = verticeCount;
                verticeCount++;
                /// 加尾部半圆
                degree = degree + curDegree + startDegree;
                curVertice = new Vector3(Mathf.Cos(degree) * cur_radius + trial_mid_x, Mathf.Sin(degree) * cur_radius + trial_mid_y);
                uiVertex = new UIVertex();
                uiVertex.color = color;
                uiVertex.position = curVertice;
                uiVertex.uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY);
                vh.AddVert(uiVertex);
                // 添加一个三角形
                vh.AddTriangle(tt_startidx, verticeCount, tt_endidx);
                tt_endidx = verticeCount;
                verticeCount++;
            }
        }
    }
}