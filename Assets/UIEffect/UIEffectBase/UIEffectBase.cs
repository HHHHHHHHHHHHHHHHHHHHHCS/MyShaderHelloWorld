﻿using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


namespace UIEffect
{
    /// <summary>
    /// UI 特效基础接口
    /// </summary>
    [RequireComponent(typeof(Graphic))]
    [DisallowMultipleComponent]
    public abstract class UIEffectBase : BaseMeshEffect, IParameterTexture
#if UNITY_EDITOR
    , ISerializationCallbackReceiver
#endif
    {
        /// <summary>
        /// 字符串,单个分割用
        /// </summary>
        protected static readonly Vector2[] splitedCharacterPosition = { Vector2.up, Vector2.one, Vector2.right, Vector2.zero };
        /// <summary>
        /// UI的顶点
        /// </summary>
        protected static readonly List<UIVertex> tempVerts = new List<UIVertex>();

        /// <summary>
        /// 特效的index
        /// </summary>
        public int ParameterIndex { get; set; }

        /// <summary>
        /// 参数的图片
        /// </summary>
        public virtual ParameterTexture ParaTex { get; }

        /// <summary>
        /// 目标的图形类
        /// </summary>
        public Graphic TargetGraphic => graphic;

        /// <summary>
        /// 特效的材质球
        /// </summary>
        [field: SerializeField]
        public Material EffectMaterial { get; protected set; }

#if UNITY_EDITOR

        /// <summary>
        /// 点击reset的时候
        /// </summary>
        protected override void Reset()
        {
            OnValidate();
        }

        /// <summary>
        /// 当在编辑面板数据改变的时候,跟着修改效果
        /// </summary>
        protected override void OnValidate()
        {
            var mat = GetMaterial();
            if (mat != EffectMaterial)
            {
                EffectMaterial = mat;
                UnityEditor.EditorUtility.SetDirty(this);
            }

            ModifyMaterial();
            TargetGraphic.SetVerticesDirty();
            SetDirty();
        }

        public void OnBeforeSerialize()
        {
        }

        public void OnAfterDeserialize()
        {

        }

        protected virtual void UpgradeIfNeeded()
        {
        }

        /// <summary>
        /// 得到材质球
        /// </summary>
        protected virtual Material GetMaterial()
        {
            return EffectMaterial;
        }
#endif

        /// <summary>
        /// 根据是否激活,设置材质或者清除材质
        /// </summary>
        public virtual void ModifyMaterial()
        {
            TargetGraphic.material = isActiveAndEnabled ? EffectMaterial : null;
        }

        /// <summary>
        /// 激活时 注册特效 设置材质球 设置数据 刷新UI
        /// </summary>
        protected override void OnEnable()
        {
            ParaTex?.Register(this);
            ModifyMaterial();
            TargetGraphic.SetVerticesDirty();
            SetDirty();
        }

        /// <summary>
        /// 隐藏时 注销特效 清除材质球 刷新UI
        /// </summary>
        protected override void OnDisable()
        {
            ModifyMaterial();
            TargetGraphic.SetVerticesDirty();
            ParaTex?.Unregister(this);
        }

        /// <summary>
        /// 手动设置数据 刷新UI
        /// </summary>
        protected virtual void SetDirty()
        {
            TargetGraphic.SetVerticesDirty();
        }

        /// <summary>
        /// 被动画属性更改的时候 
        /// </summary>
        protected override void OnDidApplyAnimationProperties()
        {
            SetDirty();
        }
    }
}