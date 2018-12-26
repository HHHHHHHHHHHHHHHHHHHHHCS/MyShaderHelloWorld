using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// ui常见的特效
    /// </summary>
    [RequireComponent(typeof(Graphic)), ExecuteInEditMode, DisallowMultipleComponent]
    public class UIEffect : UIEffectBase
    {
        /// <summary>
        /// shader名字
        /// </summary>
        private const string shaderName = "UI/S_UIEffect";
        /// <summary>
        /// 参数图片
        /// </summary>
        private static readonly ParameterTexture paraTex = new ParameterTexture(4, 1024, "_ParamTex");

        [SerializeField, Range(0, 1), Tooltip("特效的影响程度")]
        private float effectFactor = 1;

        public float EffectFactor { get; set; }

        public override void ModifyMesh(VertexHelper vh)
        {
            
        }
    }
}