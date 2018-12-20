using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// UI 特效基础接口
    /// </summary>
    [RequireComponent(typeof(Graphic))]
    [DisallowMultipleComponent]
    public abstract class UIEffectBase : BaseMeshEffect,IParameterTexture
    {
        /// <summary>
        /// 分割字符位置用
        /// </summary>
        protected static readonly Vector2[] splitedCharacterPosition
            = { Vector2.up, Vector2.one, Vector2.right, Vector2.zero };

        /// <summary>
        /// UI的顶点
        /// </summary>
        protected static readonly List<UIVertex> tempVerts
            = new List<UIVertex>();

        /// <summary>
        /// 特效的index
        /// </summary>
        public int parameterIndex { get; set; }

        /// <summary>
        /// 参数的图片
        /// </summary>
        public virtual ParameterTexture ParaTex { get; }

        /// <summary>
        /// 目标的图形类
        /// </summary>
        public Graphic TargetGraphic { get; private set; }

        /// <summary>
        /// 特效的材质球
        /// </summary>
        [field:SerializeField]
        public Material EffectMaterial { get;protected set; }

        /// <summary>
        /// 根据是否激活设置材质或者清除材质
        /// </summary>
        public void ModifyMaterial()
        {
            //TargetGraphic.material = isActiveAndEnabled ? EffectMaterial : null;
        }

        /// <summary>
        /// 激活时 注册特效 清除之前的数据
        /// </summary>
        protected override void OnEnable()
        {
            ParaTex?.Register(this);

            ModifyMaterial();
            //TargetGraphic.SetVerticesDirty();
            SetDirty();
        }


        /// <summary>
        /// 隐藏时 注销特效 清除之前的数据
        /// </summary>
        protected override void OnDisable()
        {
            ModifyMaterial();
            //TargetGraphic.SetVerticesDirty();
            ParaTex?.Unregister(this);
        }

        /// <summary>
        /// 手动清除数据
        /// </summary>
        protected virtual void SetDirty()
        {
            //TargetGraphic.SetVerticesDirty();
        }

        /// <summary>
        /// 动画属性更改的时候 
        /// </summary>
        protected override void OnDidApplyAnimationProperties()
        {
            SetDirty();
        }
    }

}


