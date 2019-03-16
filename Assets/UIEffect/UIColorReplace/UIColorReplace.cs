using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 颜色直接替换
    /// </summary>
    public class UIColorReplace : UIEffectBase
    {
        public const string shaderName = "UI/S_UIColorReplace";
        private static readonly ParameterTexture paramTex = new ParameterTexture(7, 128, "_ParamTex");

        [Header("要被替换的颜色")]
        /// <summary>
        /// 要被替换的颜色/目标颜色
        /// </summary>
        [ColorUsage(false), SerializeField, Tooltip("要被替换的颜色")]
        private Color targetColor = Color.red;

        /// <summary>
        /// 颜色识别的范围
        /// </summary>
        [Range(0, 3f), SerializeField, Tooltip("颜色识别的范围")]
        private float range = 0.1f;


        [Header("替换后的颜色")]
        /// <summary>
        /// 替换后的颜色
        /// </summary>
        [ColorUsage(false), SerializeField, Tooltip("替换后的颜色")]
        private Color replaceColor = Color.red;

        /// <summary>
        /// 参数图
        /// </summary>
        public override ParameterTexture ParamTex => paramTex;

        /// <summary>
        /// 要被替换的颜色
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
        /// 颜色识别的范围
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
        /// 替换后的颜色
        /// </summary>
        public Color ReplaceColor
        {
            get => replaceColor;
            set
            {
                if (replaceColor != value)
                {
                    replaceColor = value;
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

        /// <summary>
        /// 设置参数
        /// </summary>
        protected override void SetDirty()
        {
            ParamTex.RegisterMaterial(TargetGraphic.material);
            ParamTex.SetData(this, 0, targetColor.r); //param1.x:要被替换的颜色的r
            ParamTex.SetData(this, 1, targetColor.g); //param1.y:要被替换的颜色的g
            ParamTex.SetData(this, 2, targetColor.b); //param1.z:要被替换的颜色的b
            ParamTex.SetData(this, 3, range/3); //param1.w:识别的范围
            ParamTex.SetData(this, 4, replaceColor.r ); //param2.x:替换后的颜色的r
            ParamTex.SetData(this, 5, replaceColor.g); //param2.y:替换后的颜色的g
            ParamTex.SetData(this, 6, replaceColor.b); //param2.z:替换后的颜色的b
        }

#if UNITY_EDITOR
        protected override Material GetMaterial()
        {
            return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName));
        }
#endif
    }

}
