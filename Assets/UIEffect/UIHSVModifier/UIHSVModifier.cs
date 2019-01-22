using System.Collections;
using System.Collections.Generic;
using UIEffect;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// HSV 颜色替换
    /// </summary>
    public class UIHSVModifier : UIEffectBase
    {
        public const string shaderName = "UI/S_UIHSVModifier";
        private static readonly ParameterTexture paramTex = new ParameterTexture(7, 128, "_ParamTex");

        [Header("要被偏移的颜色")]
        /// <summary>
        /// 要被偏移的颜色/目标颜色
        /// </summary>
        [ColorUsage(false), SerializeField, Tooltip("要被偏移的颜色/目标颜色")]
        private Color targetColor = Color.red;

        /// <summary>
        /// 颜色偏移的范围
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("颜色偏移的范围")]
        private float range = 0.1f;


        [Header("偏移后")]
        /// <summary>
        /// 色调的偏移
        /// </summary>
        [Range(-0.5f, 0.5f), SerializeField, Tooltip("偏移后色调的偏移")]
        private float hue;

        /// <summary>
        /// 饱和度的偏移
        /// </summary>
        [Range(-0.5f, 0.5f), SerializeField, Tooltip("偏移后饱和度的偏移")]
        private float saturation;

        /// <summary>
        /// 明度/曝光度的偏移,用Value可能会命名冲突
        /// </summary>
        [Range(-0.5f, 0.5f), SerializeField, Tooltip("明度/曝光度的偏移")]
        private float shiftValue;

        /// <summary>
        /// 参数图
        /// </summary>
        public override ParameterTexture ParamTex => paramTex;

        /// <summary>
        /// 要被偏移的颜色/目标颜色
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
        /// 颜色偏移的范围
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
        /// 色调的偏移
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
        /// 饱和度的偏移
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
        /// 明度/曝光度的偏移,用Value可能会命名冲突
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
            //不在shader里面转是因为会计算多次
            Color.RGBToHSV(targetColor, out float h, out float s, out float v);
            
            ParamTex.RegisterMaterial(TargetGraphic.material);
            ParamTex.SetData(this, 0, h); //param1.x:要被偏移的颜色的色调
            ParamTex.SetData(this, 1, s); //param1.y:要被偏移的颜色的饱和度
            ParamTex.SetData(this, 2, v); //param1.z:要被偏移的颜色的曝光度
            ParamTex.SetData(this, 3, range); //param1.w:识别的范围
            //加0.5转正,因为color不支持负数
            ParamTex.SetData(this, 4, hue + 0.5f); //param2.x:色调的偏移
            ParamTex.SetData(this, 5, saturation + 0.5f); //param2.y:饱和度的偏移
            ParamTex.SetData(this, 6, shiftValue + 0.5f); //param2.z:曝光度的偏移
        }

#if UNITY_EDITOR
        protected override Material GetMaterial()
        {
            return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName));
        }
#endif
    }

}