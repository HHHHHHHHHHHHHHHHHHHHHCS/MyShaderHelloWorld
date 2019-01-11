using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// UI过渡用
    /// </summary>
    public class UITransition : UIDynamicBase
    {
        /// <summary>
        /// shader名字
        /// </summary>
        public const string shaderName = "UI/S_UITransition";

        /// <summary>
        /// 特效参数用
        /// </summary>
        private static readonly ParameterTexture paramTex = new ParameterTexture(8, 128, "_ParamTex");

        /// <summary>
        /// 过渡效果
        /// </summary>
        [SerializeField, Tooltip("过渡效果")] private TransitionMode transitionMode = TransitionMode.Cutoff;

        /// <summary>
        /// 特效图,单通道颜色图
        /// </summary>
        [SerializeField, Tooltip("特效参数图,单通道颜色图")]
        private Texture transitionTexture;

        /// <summary>
        /// 特效影响区域
        /// </summary>
        [SerializeField, Tooltip("特效影响区域")] private EffectArea effectArea = EffectArea.RectTransform;

        /// <summary>
        /// 是否用特效参数图的缩放比
        /// </summary>
        [SerializeField, Tooltip("保持特效参数图缩放比例")]
        private bool keepAspectRatio;

        /// <summary>
        /// 溶解边缘的宽度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("溶解边缘的宽度")]
        private float dissolveWidth = 0.5f;

        /// <summary>
        /// 溶解边缘的软边
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("溶解边缘的软边")]
        private float dissolveSoftness = 0.5f;

        /// <summary>
        /// 溶解边缘的颜色
        /// </summary>
        [SerializeField, ColorUsage(false), Tooltip("溶解边缘的颜色")]
        private Color dissolveColor = new Color(0f, 0.25f, 1f);

        /// <summary>
        /// 点击之后隐藏效果
        /// </summary>
        [SerializeField, Tooltip("点击之后隐藏效果")] private bool passRayOnHidden = false;

        /// <summary>
        /// 特效图,单通道颜色图
        /// </summary>
        public Texture TransitionTexture
        {
            get => transitionTexture;
            set
            {
                if (transitionTexture != value)
                {
                    transitionTexture = value;
                    if (TargetGraphic)
                    {
                        ModifyMaterial();
                    }
                }
            }
        }

        //TODO:
        public TransitionMode TransitionMode
        {
            get => transitionMode;
            set
            {
                if (transitionMode != value)
                {
                    transitionMode = value;
                    SetDirty();
                }
            }
        }

        public override ParameterTexture ParamTex => paramTex;


        public override void ModifyMesh(VertexHelper vh)
        {
        }
    }
}