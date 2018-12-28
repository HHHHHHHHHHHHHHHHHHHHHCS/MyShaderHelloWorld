using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 溶解的效果
    /// 噪音图建议设置单通道,用灰度当alpha
    /// </summary>
    public class UIDissolve : UIDynamicBase
    {
        /// <summary>
        /// 溶解的shader名字
        /// </summary>
        private const string shaderName = "UI/S_UIDissolve";

        /// <summary>
        /// 参数图
        /// </summary>
        private static readonly ParameterTexture paraTex = new ParameterTexture(8, 128, "_ParamTex");

        /// <summary>
        /// 溶解的宽度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("溶解的宽度")]
        private float width = 0.5f;

        /// <summary>
        /// 溶解的软边
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("溶解的软边")]
        private float softness = 0.5f;

        /// <summary>
        /// 溶解的边颜色
        /// </summary>
        [SerializeField, ColorUsage(false), Tooltip("溶解的边颜色")]
        private Color dissolveColor = new Color(0f, 0.25f, 1f);

        /// <summary>
        /// 溶解的边的颜色模式
        /// </summary>
        [SerializeField, Tooltip("溶解的边的颜色模式")] private ColorMode colorMode = ColorMode.Add;

        /// <summary>
        /// 溶解的噪音图
        /// </summary>
        [SerializeField, Tooltip("溶解的噪音图")] private Texture noiseTexture;

        /// <summary>
        /// 特效影响区域
        /// </summary>
        [SerializeField, Tooltip("特效影响区域")] private EffectArea effectArea;

        /// <summary>
        /// 噪音图的自适应
        /// </summary>
        [SerializeField, Tooltip("噪音图的自适应")] private bool keepAspectRatio;

        /// <summary>
        /// 溶解的宽度
        /// </summary>
        public float Width
        {
            get => width;
            set
            {
                if (Mathf.Approximately(width, value))
                {
                    width = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的软边
        /// </summary>
        public float Softness
        {
            get => softness;
            set
            {
                if (Mathf.Approximately(softness, value))
                {
                    softness = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的边颜色
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
        /// 溶解的边的颜色模式
        /// </summary>
        public ColorMode ColorMode
        {
            get => colorMode;
            set
            {
                if (colorMode != value)
                {
                    colorMode = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 溶解的噪音图,如果没有设置图片,则用材质球默认的
        /// </summary>
        public Texture NoiseTexture
        {
            get => noiseTexture ?? TargetGraphic.material.GetTexture("_NoiseTex");

            set
            {
                if (noiseTexture != value)
                {
                    noiseTexture = value;
                    if (TargetGraphic)
                    {
                        ModifyMaterial();
                    }
                }
            }
        }

        /// <summary>
        /// 特效影响区域
        /// </summary>
        public EffectArea EffectArea
        {
            get => effectArea;
            set
            {
                if (effectArea != value)
                {
                    effectArea = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 噪音图的自适应
        /// </summary>
        public bool KeepAspectRatio
        {
            get => keepAspectRatio;
            set
            {
                if (keepAspectRatio != value)
                {
                    keepAspectRatio = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 参数图
        /// </summary>
        public override ParameterTexture ParaTex => paraTex;

        /// <summary>
        /// 材质球缓存用
        /// </summary>
        private MaterialCache materialCache;

        /// <summary>
        /// 根据是否激活修改材质球
        /// </summary>
        public override void ModifyMaterial()
        {
            //材质球缓存id
            ulong hash = (noiseTexture ? (ulong)noiseTexture.GetInstanceID() : 0)
                         + ((ulong)1 << 32) + ((ulong)ColorMode << 36);

            //材质hash不一样||隐藏||没有设置材质
            //注销缓存
            if ((materialCache != null && materialCache.Hash != hash) || !isActiveAndEnabled || !EffectMaterial)
            {
                MaterialCache.Unregister(materialCache);
                materialCache = null;
            }

            if (!isActiveAndEnabled || !EffectMaterial)
            {//组件隐藏||没有设置材质
                TargetGraphic.material = null;
            }
            else if (!noiseTexture)
            {//如果没有噪音图,则用默认的材质球,没有必要专门用材质球缓存
                TargetGraphic.material = EffectMaterial;
            }
            else if (materialCache != null && materialCache.Hash == hash)
            {//材质球hash一样,并且有缓存了,用材质球缓存
                TargetGraphic.material = materialCache.MainMaterial;
            }
            else
            {//注册材质球缓存,并且设置
                materialCache = MaterialCache.Register(hash, noiseTexture,
                    () =>
                    {
                        var mat = new Material(EffectMaterial);
                        mat.name += "_" + noiseTexture.name;
                        mat.SetTexture("_NoiseTex", noiseTexture);
                        return mat;
                    });
                graphic.material = materialCache.MainMaterial;
            }
        }

        /// <summary>
        /// 修改顶点数据,得到效果
        /// </summary>
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled)
            {//组件隐藏,直接跳出 节省性能
                return;
            }

            //参数图索引
            float normalizedIndex = ParaTex.GetNormalizedIndex(this);

            //得到特效的区域矩形
            var tex = NoiseTexture;
            var aspectRatio = KeepAspectRatio && tex ? ((float)tex.width / tex.height) : -1;
            Rect rect = EffectArea.GetEffectArea(vh, TargetGraphic, aspectRatio);

            UIVertex vertex = default;
            bool effectEachCharacter = graphic is Text && EffectArea == EffectArea.Character;
            float x, y;//在噪音图上的UV坐标
            int count = vh.currentVertCount;
            for (int i = 0; i < count; i++)
            {
                vh.PopulateUIVertex(ref vertex, i);
                if (effectEachCharacter)
                {
                    x = splitedCharacterPosition[i % 4].x;
                    y = splitedCharacterPosition[i % 4].y;
                }
                else
                {
                    //因为中心点是坐标0 左边点是负数 所以要加 0.5f 映射到0-1
                    x = Mathf.Clamp01(vertex.position.x / rect.width + 0.5f);
                    y = Mathf.Clamp01(vertex.position.y / rect.height + 0.5f);
                }

                //设置UV参数
                //x:原来的uv.x,uv.y
                //y:x,y->在噪音图上的uv坐标,参数图索引
                vertex.uv0 = new Vector2(
                    Packer.ToFloat(vertex.uv0.x, vertex.uv0.y)
                    , Packer.ToFloat(x, y, normalizedIndex));

                vh.SetUIVertex(vertex, i);
            }
        }

        /// <summary>
        /// 手动设置数据 刷新UI
        /// </summary>
        protected override void SetDirty()
        {
            ParaTex.RegisterMaterial(TargetGraphic.material);
            ParaTex.SetData(this, 0, EffectFactor); //param1.x:播放的进度
            ParaTex.SetData(this, 1, Width); //param1.y:溶解的宽度
            ParaTex.SetData(this, 2, Softness); //param1.z:溶解的软边
            ParaTex.SetData(this, 4, DissolveColor.r); //param2.x:溶解的颜色R
            ParaTex.SetData(this, 5, DissolveColor.g); //param2.y:溶解的颜色G
            ParaTex.SetData(this, 6, DissolveColor.b); //param2.z:溶解的颜色B
        }

        /// <summary>
        /// 隐藏的时候注销材质缓存 注销特效图片参数
        /// </summary>
        protected override void OnDisable()
        {
            MaterialCache.Unregister(materialCache);
            materialCache = null;
            base.OnDisable();
        }
#if UNITY_EDITOR
        protected override Material GetMaterial()
        {
            return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName), ColorMode);
        }
#endif
    }
}