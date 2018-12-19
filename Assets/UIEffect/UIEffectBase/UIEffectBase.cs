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
#if UNITY_EDITOR
    ,ISerializationCallbackReceiver
#endif
    {
        /// <summary>
        /// 分割字符位置
        /// </summary>
        protected static readonly Vector2[] splitedCharacterPosition
            = { Vector2.up, Vector2.one, Vector2.right, Vector2.zero };

        /// <summary>
        /// UI的顶点
        /// </summary>
        protected static readonly List<UIVertex> tempVerts
            = new List<UIVertex>();

        /// <summary>
        /// 当前的版本
        /// </summary>
        [HideInInspector, SerializeField]
        private int version;

        /// <summary>
        /// 特效的index
        /// </summary>
        public int parameterIndex { get; set; }

        /// <summary>
        /// 参数的图片
        /// </summary>
        public ParameterTexture ParaTex { get; }

        /// <summary>
        /// 目标的图形类
        /// </summary>
        public Graphic TargetGraphic { get; private set; }

        /// <summary>
        /// 特效的材质球
        /// </summary>
        [field:SerializeField]
        public Material EffectMaterial { get;protected set; }
#if UNITY_EDITOR
        /// <summary>
        /// Inspector点击reset的时候用
        /// </summary>
        protected override void Reset()
        {
            version = 300;
        }

        /// <summary>
        /// 重置数据 编辑状态才需要
        /// </summary>
        protected override void OnValidate()
        {
            var mat = GetMaterial();
            if (EffectMaterial != mat)
            {
                EffectMaterial = mat;
                UnityEditor.EditorUtility.SetDirty(this);
            }

            ModifyMaterial();
            //TargetGraphic.SetVerticesDirty();
            SetDirty();
        }

        public void OnBeforeSerialize()
        {
            
        }

        public void OnAfterDeserialize()
        {
            UnityEditor.EditorApplication.delayCall += UpdateIfNeeded;
        }

        protected bool IsShouldUpgrade(int expectedVersion)
        {
            if (version < expectedVersion)
            {
                Debug.LogFormat(gameObject, "<b>{0}({1})</b> has been upgraded: <i>version {2} -> {3}</i>", name, GetType().Name, version, expectedVersion);
                version = expectedVersion;

                //UnityEditor.EditorApplication.delayCall += () =>
                {
                    UnityEditor.EditorUtility.SetDirty(this);
                    if (!Application.isPlaying && gameObject && gameObject.scene.IsValid())
                    {
                        UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(gameObject.scene);
                    }
                }
                ;
                return true;
            }
            return false;
        }

        /// <summary>
        /// 看是否能更新材质
        /// </summary>
        protected virtual void UpdateIfNeeded()
        {

        }

        /// <summary>
        /// 得到材质球
        /// </summary>
        /// <returns></returns>
        public virtual Material GetMaterial()
        {
            return null;
        }
#endif

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


