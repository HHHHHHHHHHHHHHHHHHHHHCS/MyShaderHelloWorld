using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 颜色梯度
    /// </summary>
    public class UIGradient : BaseMeshEffect
    {
        /// <summary>
        /// 颜色梯度的方向
        /// </summary>
        [SerializeField, Tooltip("颜色梯度的方向")] private Direction direction;

        /// <summary>
        /// Color1:顶部或者左边
        /// </summary>
        [SerializeField, Tooltip("Color1:顶部或者左边")]
        private Color color1 = Color.white;

        /// <summary>
        /// Color2:底部或者右边
        /// </summary>
        [SerializeField, Tooltip("Color2:底部或者右边")]
        private Color color2 = Color.white;

        /// <summary>
        /// Color3:Diagonal用
        /// </summary>
        [SerializeField, Tooltip("Color3:Diagonal用")]
        private Color color3 = Color.white;

        /// <summary>
        /// Color4:Diagonal用
        /// </summary>
        [SerializeField, Tooltip("Color4:Diagonal用")]
        private Color color4 = Color.white;

        /// <summary>
        /// 颜色梯度旋转
        /// </summary>
        [Range(-180, 180), SerializeField, Tooltip("颜色梯度旋转")]
        private float rotation;

        /// <summary>
        /// 颜色梯度偏移,横,竖,或者角度
        /// </summary>
        [Range(-1, 1), SerializeField, Tooltip("颜色梯度偏移,横,竖,或者角度")]
        private float offset1;

        /// <summary>
        /// 颜色梯度Diagonal用
        /// </summary>
        [Range(-1, 1), SerializeField, Tooltip("颜色梯度Diagonal用")]
        private float offset2;

        /// <summary>
        /// 特效区域模式
        /// </summary>
        [SerializeField, Tooltip("特效区域模式")] private EffectArea effectArea;

        /// <summary>
        /// 颜色空间模式
        /// </summary>
        [SerializeField, Tooltip("颜色空间模式")] private ColorSpace colorSpace = ColorSpace.Uninitialized;

        /// <summary>
        /// 忽略自适应?
        /// </summary>
        [SerializeField, Tooltip("忽略自适应?")] private bool ignoreAspectRatio = true;

        /// <summary>
        /// 目标图形
        /// </summary>
        public Graphic TargetGraphic => graphic;

        /// <summary>
        /// 颜色梯度的方向
        /// </summary>
        public Direction Direction
        {
            get => direction;
            set
            {
                if (direction != value)
                {
                    direction = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// Color1:顶部或者左边
        /// </summary>
        public Color Color1
        {
            get => color1;
            set
            {
                if (color1 != value)
                {
                    color1 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// Color2:底部或者右边
        /// </summary>
        public Color Color2
        {
            get => color2;
            set
            {
                if (color2 != value)
                {
                    color2 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// Color3:Diagonal用
        /// </summary>
        public Color Color3
        {
            get => color3;
            set
            {
                if (color3 != value)
                {
                    color3 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// Color4:Diagonal用
        /// </summary>
        public Color Color4
        {
            get => color4;
            set
            {
                if (color4 != value)
                {
                    color4 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 颜色梯度旋转
        /// </summary>
        public float Rotation
        {
            get => direction == Direction.Horizontal ? -90
                : direction == Direction.Vertical ? 0
                : rotation;
            set
            {
                if (!Mathf.Approximately(rotation, value))
                {
                    rotation = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 颜色梯度偏移,横,竖,或者角度
        /// </summary>
        public float Offset1
        {
            get => offset1;

            set
            {
                if (!Mathf.Approximately(offset1, value))
                {
                    offset1 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 颜色梯度Diagonal用
        /// </summary>
        public float Offset2
        {
            get => offset2;

            set
            {
                if (!Mathf.Approximately(offset2, value))
                {
                    offset2 = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 梯度区域模式
        /// </summary>
        public EffectArea EffectArea
        {
            get => effectArea;
            set
            {
                if (effectArea != value)
                {
                    effectArea = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 忽略自适应?
        /// </summary>
        public bool IgnoreAspectRatio
        {
            get => ignoreAspectRatio;
            set
            {
                if (ignoreAspectRatio != value)
                {
                    ignoreAspectRatio = value;
                    graphic.SetVerticesDirty();
                }
            }
        }

        public override void ModifyMesh(VertexHelper vh)
        {
            if (!IsActive())
            {
                return;
            }

            Rect rect = effectArea.GetEffectArea(vh, TargetGraphic);
            ;
            UIVertex vertex = default;

            float rad = rotation * Mathf.Deg2Rad;
            Vector2 dir = new Vector2(Mathf.Cos(rad), Mathf.Sin(rad));
            if (!ignoreAspectRatio && direction >= Direction.Angle)
            {
                dir.x *= rect.height / rect.width;
                dir = dir.normalized;
            }
            //todo:
        }
    }
}