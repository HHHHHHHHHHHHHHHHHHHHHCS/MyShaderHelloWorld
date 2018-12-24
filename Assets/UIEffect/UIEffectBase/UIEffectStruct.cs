using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 特效的区域用
    /// </summary>
    public enum EffectArea
    {
        RectTransform,
        Fit,
        Character,
    }

    /// <summary>
    /// 特效的区域扩展
    /// </summary>
    public static class EffectAreaExtensions
    {
        /// <summary>
        /// 单个字符流光 Text组件用的框
        /// </summary>
        static readonly Rect rectForCharacter = new Rect(0, 0, 1, 1);

        /// <summary>
        /// 得到特效的矩形区域
        /// </summary>
        /// <param name="area">矩形区域的枚举</param>
        /// <param name="vh">UI的顶点</param>
        /// <param name="graphic">UI基础类型</param>
        /// <param name="aspectRatio">宽度/高度的比例</param>
        /// <returns>矩形区域</returns>
        public static Rect GetEffectArea(this EffectArea area, VertexHelper vh, Graphic graphic, float aspectRatio = -1)
        {
            Rect rect = default(Rect);
            switch (area)
            {
                case EffectArea.RectTransform:
                    rect = graphic.rectTransform.rect;
                    break;
                case EffectArea.Character:
                    rect = rectForCharacter;
                    break;
                case EffectArea.Fit:
                    // Fit to contents.
                    UIVertex vertex = default;
                    rect.xMin = rect.yMin = float.MaxValue;
                    rect.xMax = rect.yMax = float.MinValue;
                    for (int i = 0; i < vh.currentVertCount; i++)
                    {
                        vh.PopulateUIVertex(ref vertex, i);
                        rect.xMin = Mathf.Min(rect.xMin, vertex.position.x);
                        rect.yMin = Mathf.Min(rect.yMin, vertex.position.y);
                        rect.xMax = Mathf.Max(rect.xMax, vertex.position.x);
                        rect.yMax = Mathf.Max(rect.yMax, vertex.position.y);
                    }

                    break;
                default:
                    rect = graphic.rectTransform.rect;
                    break;
            }


            if (aspectRatio > 0)
            {
                if (rect.width < rect.height)
                {
                    rect.width = rect.height * aspectRatio;
                }
                else
                {
                    rect.height = rect.width / aspectRatio;
                }
            }

            return rect;
        }
    }

    /// <summary>
    /// 矩阵2行3竖
    /// 流光用 用于标准化顶点位置
    /// </summary>
    public struct Matrix2x3
    {
        public float m00, m01, m02, m10, m11, m12;

        public Matrix2x3(Rect rect, float cos, float sin)
        {
            const float center = 0.5f;
            float dx = -rect.xMin / rect.width - center;
            float dy = -rect.yMin / rect.height - center;
            m00 = cos / rect.width;
            m01 = -sin / rect.height;
            m02 = dx * cos - dy * sin + center;
            m10 = sin / rect.width;
            m11 = cos / rect.height;
            m12 = dx * sin + dy * cos + center;
        }

        public static Vector2 operator *(Matrix2x3 m, Vector2 v)
        {
            return new Vector2(
                (m.m00 * v.x) + (m.m01 * v.y) + m.m02,
                (m.m10 * v.x) + (m.m11 * v.y) + m.m12
            );
        }
    }
}