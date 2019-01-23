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
        /// 播放的时候是否能点击,即Mask的效果
        /// </summary>
        [SerializeField, Tooltip("播放的时候是否能点击,即Mask的效果")]
        private bool passRayOnHidden = false;

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

        /// <summary>
        /// 过渡模式
        /// </summary>
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

        /// <summary>
        /// 用噪音图的纵横比
        /// </summary>
        public bool KeepAspectRatio
        {
            get => keepAspectRatio;
            set
            {
                if (keepAspectRatio != value)
                {
                    keepAspectRatio = value;
                    TargetGraphic.SetVerticesDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的宽度
        /// </summary>
        public float DissolveWidth
        {
            get => dissolveWidth;
            set
            {
                if (dissolveWidth != value)
                {
                    dissolveWidth = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的软边
        /// </summary>
        public float DissolveSoftness
        {
            get => dissolveSoftness;
            set
            {
                if (dissolveSoftness != value)
                {
                    dissolveSoftness = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的颜色
        /// </summary>
        public Color DissolveColor
        {
            get => dissolveColor;
            set
            {
                if (dissolveColor != value)
                {
                    dissolveColor = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 播放的时候是否能点击,即Mask的效果
        /// </summary>
        public bool PassRayOnHidden
        {
            get => passRayOnHidden;
            set
            {
                if (passRayOnHidden != value)
                {
                    passRayOnHidden = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效参数图
        /// </summary>
        public override ParameterTexture ParamTex => paramTex;

        private MaterialCache materialCache;

        /// <summary>
        /// 显示
        /// </summary>
        public void Show()
        {
            player.loop = false;
            player.Play(f => EffectFactor = f);
        }

        /// <summary>
        /// 隐藏
        /// </summary>
        public void Hide()
        {
            player.loop = false;
            player.Play(f => EffectFactor = 1 - f);
        }

        /// <summary>
        /// 激活的时候,设置播放事件
        /// </summary>
        protected override void OnEnable()
        {
            base.OnEnable();
            player.OnEnable();
            player.loop = false;
        }

        /// <summary>
        /// 隐藏的时候,取消播放事件,注销缓存材质
        /// </summary>
        protected override void OnDisable()
        {
            MaterialCache.Unregister(materialCache);
            materialCache = null;
            base.OnDisable();
            player.OnDisable();
        }

        /// <summary>
        /// 修改材质球,有材质球缓存
        /// </summary>
        public override void ModifyMaterial()
        {
            ulong hash = (TransitionTexture ? (uint) TransitionTexture.GetInstanceID() : 0)
                         + ((ulong) 2 << 32) + ((ulong) TransitionMode << 36);
            if (materialCache != null && (materialCache.Hash != hash
                                          || !isActiveAndEnabled || !EffectMaterial))
            {
                MaterialCache.Unregister(materialCache);
                materialCache = null;
            }

            if (!isActiveAndEnabled || !EffectMaterial)
            {
                TargetGraphic.material = null;
            }
            else if (!transitionTexture)
            {
                TargetGraphic.material = EffectMaterial;
            }
            else if (materialCache != null && materialCache.Hash == hash)
            {
                graphic.material = materialCache.MainMaterial;
            }
            else
            {
                materialCache = MaterialCache.Register(hash, TransitionTexture, () =>
                {
                    var mat = new Material(EffectMaterial);
                    mat.name += "_" + TransitionTexture.name;
                    mat.SetTexture("_TransitionTexture", TransitionTexture);
                    return mat;
                });
                TargetGraphic.material = materialCache.MainMaterial;
            }
        }

        /// <summary>
        /// 修改顶点数据
        /// </summary>
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled)
            {
                return;
            }

            var tex = transitionTexture;
            var aspectRatio = KeepAspectRatio && tex ? (float) tex.width / tex.height : -1;
            Rect rect = effectArea.GetEffectArea(vh, graphic, aspectRatio);

            float normalizedIndex = paramTex.GetNormalizedIndex(this);
            UIVertex vertex = default;
            bool effectEachCharacter = TargetGraphic is Text && effectArea == EffectArea.Character;

            float x, y;
            int count = vh.currentVertCount;

            for (int i = 0; i < count; i++)
            {
                vh.PopulateUIVertex(ref vertex, i);

                if (effectEachCharacter)
                {
                    x = ConstData.splitedCharacterPosition[i % 4].x;
                    y = ConstData.splitedCharacterPosition[i % 4].y;
                }
                else
                {
                    //因为顶点位置是存在负数的,+0.5偏移补正成UV
                    x = Mathf.Clamp01(vertex.position.x / rect.width + 0.5f);
                    y = Mathf.Clamp01(vertex.position.y / rect.height + 0.5f);
                }

                //打包原来的UV,特效用区域位置,特效索引
                vertex.uv0 = new Vector2(
                    Packer.ToFloat(vertex.uv0.x, vertex.uv0.y)
                    , Packer.ToFloat(x, y, normalizedIndex));
                vh.SetUIVertex(vertex, i);
            }
        }

        /// <summary>
        /// 设置数据
        /// </summary>
        protected override void SetDirty()
        {
            ParamTex.RegisterMaterial(TargetGraphic.material); //注册材质
            ParamTex.SetData(this, 0, EffectFactor); //para0:x 播放进度
            if (TransitionMode == TransitionMode.Dissolve)
            {
                ParamTex.SetData(this, 1, DissolveWidth); //para0:z 溶解宽度
                ParamTex.SetData(this, 2, DissolveSoftness); //para0:z 溶解软边
                ParamTex.SetData(this, 4, DissolveColor.r); //para1.x 溶解的颜色R
                ParamTex.SetData(this, 5, DissolveColor.g); //para1.g 溶解的颜色G
                ParamTex.SetData(this, 6, DissolveColor.b); //para1.b 溶解的颜色B
            }

            if (PassRayOnHidden)
            {
                TargetGraphic.raycastTarget = EffectFactor > 0;
            }
        }


#if UNITY_EDITOR
        /// <summary>
        /// 得到材质
        /// </summary>
        protected override Material GetMaterial()
        {
            return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName), TransitionMode);
        }
#endif
    }
}