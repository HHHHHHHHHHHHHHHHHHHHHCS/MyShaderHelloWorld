﻿using System.Collections;
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

        /// <summary>
        /// 特效的影响程度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("特效的影响程度")]
        private float effectFactor = 1;

        [SerializeField,Range(0,1),Tooltip("颜色的影响程度")]
        private float colorFactor = 1;

        [SerializeField,Range(0,1),Tooltip("模糊的影响程度")]
        private float blurFactor = 1;

        public float EffectFactor { get; set; }

        public override void ModifyMesh(VertexHelper vh)
        {
            
        }
    }
}