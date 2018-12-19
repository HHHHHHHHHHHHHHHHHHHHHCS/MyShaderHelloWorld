using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 流光特效
    /// </summary>
    [AddComponentMenu("UI/UIEffect/UIShiny", 2)]
    public class UIShiny : UIEffectBase
    {
        /// <summary>
        /// shader的名字
        /// </summary>
        private const string shaderName = "UI/S_UIShiny";
        /// <summary>
        /// 特效参数用
        /// </summary>
        private static readonly ParameterTexture paraTex = new ParameterTexture(8, 128, "_Param");

        /// <summary>
        /// 流光的位置百分比
        /// </summary>
        [SerializeField, Range(0,1),Tooltip("Location for shiny effect")]
        private float effectFactor = 0;

        /// <summary>
        /// 流光的宽度
        /// </summary>
        [SerializeField, Range(0,1),Tooltip("Width for shiny effect")]
        private float width = 0.25f;

        /// <summary>
        /// 流光的旋转
        /// </summary>
        [SerializeField, Range(-180,180),Tooltip("Width for shiny effect")]
        private float rotation = 0;

        /// <summary>
        /// 流光的渐变软边
        /// </summary>
        [SerializeField,Range(0.01f,1),Tooltip("Softness for shiny effect")]
        private float softness = 1f;

        /// <summary>
        /// 流光的亮度
        /// </summary>
        [SerializeField,Range(0,1),Tooltip("Brightness for shiny effect")]
        private float brightness = 1f;

        public override void ModifyMesh(VertexHelper vh)
        {
            
        }
    }

}


