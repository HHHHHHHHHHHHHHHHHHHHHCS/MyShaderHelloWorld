using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 流光特效
    /// </summary>
    //[AddComponentMenu("UI/UIEffect/UIShiny", 2)]
    public class UIShiny : UIEffectBase
    {
        /// <summary>
        /// shader的名字
        /// </summary>
        private const string shaderName = "UI/S_UIShiny";

        /// <summary>
        /// 特效参数用
        /// </summary>
        private static readonly ParameterTexture paraTex = new ParameterTexture(8, 128, "_ParamTex");

        /// <summary>
        /// 流光的亮度
        /// </summary>
        [SerializeField]
        [Range(0, 1)]
        [Tooltip("Brightness for shiny effect")]
        private float brightness = 1f;

        /// <summary>
        /// 流光的区域
        /// </summary>
        [SerializeField]
        [Tooltip("The area for effect")]
        protected EffectArea effectArea;

        /// <summary>
        /// 流光的位置百分比
        /// </summary>
        [SerializeField]
        [Range(0, 1)]
        [Tooltip("Location for shiny effect")]
        private float effectFactor;

        /// <summary>
        /// 流光的曝光度
        /// </summary>
        [SerializeField]
        [Range(0, 1)]
        [Tooltip("Highlight")]
        private float gloss = 1;

        /// <summary>
        /// 光柱最后的旋转角度
        /// </summary>
        private float lastRotation;

        /// <summary>
        /// 流光的播放器
        /// </summary>
        [SerializeField] protected EffectPlayer player;

        /// <summary>
        /// 流光的旋转
        /// </summary>
        [SerializeField]
        [Range(-180, 180)]
        [Tooltip("Width for shiny effect")]
        private float rotation;

        /// <summary>
        /// 流光的渐变软边
        /// </summary>
        [SerializeField]
        [Range(0.01f, 1)]
        [Tooltip("Softness for shiny effect")]
        private float softness = 1f;

        /// <summary>
        /// 流光的宽度
        /// </summary>
        [SerializeField]
        [Range(0, 1)]
        [Tooltip("Width for shiny effect")]
        private float width = 0.25f;


        /// <summary>
        /// 特效的播放进度 0~1
        /// 如果set 的值过于近似也不会有效果
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set
            {
                value = Mathf.Clamp(value, 0, 1);
                if (!Mathf.Approximately(effectFactor, value))
                {
                    effectFactor = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 设置流光的宽度
        /// </summary>
        public float Width
        {
            get => width;
            set
            {
                value = Mathf.Clamp(value, 0, 1);
                if (!Mathf.Approximately(width, value))
                {
                    width = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 设置流光的渐变软边
        /// </summary>
        public float Softness
        {
            get => softness;
            set
            {
                value = Mathf.Clamp(value, 0.01f, 1);
                if (!Mathf.Approximately(softness, value))
                {
                    softness = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 流光的光强度
        /// </summary>
        public float Brightness
        {
            get => brightness;
            set
            {
                value = Mathf.Clamp(value, 0, 1);
                if (!Mathf.Approximately(brightness, value))
                {
                    brightness = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 流光的曝光度
        /// </summary>
        public float Gloss
        {
            get => gloss;
            set
            {
                value = Mathf.Clamp(value, 0, 1);
                if (!Mathf.Approximately(gloss, value))
                {
                    gloss = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 流光的角度
        /// </summary>
        public float Rotation
        {
            get => rotation;
            set
            {
                if (!Mathf.Approximately(rotation, value))
                {
                    rotation = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效显示的区域的方式
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
        /// 流光的播放器
        /// </summary>
        protected EffectPlayer Player => player ?? (player = new EffectPlayer());

        /// <summary>
        /// 是否播放特效
        /// </summary>
        public bool PlayState
        {
            get => Player.play;
            set => Player.play = value;
        }

        /// <summary>
        /// 特效是否循环
        /// </summary>
        public bool Loop
        {
            get => Player.loop;
            set => Player.loop = value;
        }

        /// <summary>
        /// 特效播放多久
        /// </summary>
        public float Duration
        {
            get => Player.duration;
            set => Player.duration = Mathf.Max(value, 0.1f);
        }

        /// <summary>
        /// 特效播放 延迟多久再次循环播放
        /// </summary>
        public float LoopDelay
        {
            get => Player.loopDelay;
            set => Player.loopDelay = Mathf.Max(value, 0);
        }

        /// <summary>
        /// 特效的播放时间方式
        /// </summary>
        public AnimatorUpdateMode UpdateMode
        {
            get => Player.updateMode;
            set => Player.updateMode = value;
        }

        /// <summary>
        /// 得到参数图片
        /// </summary>
        public override ParameterTexture ParaTex => paraTex;

        /// <summary>
        /// 注册事件  得到动画播放的进度
        /// </summary>
        protected override void OnEnable()
        {
            base.OnEnable();
            Player.OnEnable(f => EffectFactor = f);
        }

        /// <summary>
        /// 注销事件
        /// </summary>
        protected override void OnDisable()
        {
            base.OnDisable();
            Player.OnDisable();
        }


#if UNITY_EDITOR
        protected override Material GetMaterial()
        {
            return MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName));
        }

#endif


        /// <summary>
        /// 修改mesh 的时候(比如图片改变 ,数据改变的时候)
        /// 重新设置顶点的UV数据
        /// UV.x是原UV的数据 UV.y是流光的数据
        /// </summary>
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled) return;

            //得到特效的索引
            var normalizedIndex = ParaTex.GetNormalizedIndex(this);

            //重新计算矩阵
            var rect = EffectArea.GetEffectArea(vh, graphic);

            //计算角度
            var rad = Rotation * Mathf.Deg2Rad;
            var dir = new Vector2(Mathf.Cos(rad), Mathf.Sin(rad));
            dir.x *= rect.height / rect.width;
            dir = dir.normalized;

            //是否是 Text  单个字符流光模式
            var effectEachCharacter = graphic is Text && EffectArea == EffectArea.Character;

            UIVertex vertex = default;
            var localMatrix = new Matrix2x3(rect, dir.x, dir.y); //重新计算标准化矩阵
            for (var i = 0; i < vh.currentVertCount; i++)
            {
                vh.PopulateUIVertex(ref vertex, i);

                //根据矩阵标准化顶点位置
                var vertexPos = effectEachCharacter
                ? splitedCharacterPosition[i % 4]
                : (Vector2)vertex.position;
                var normalizedPos = localMatrix * vertexPos;

                vertex.uv0 = new Vector2(
                Packer.ToFloat(vertex.uv0.x, vertex.uv0.y), //原来的UV
                Packer.ToFloat(normalizedPos.y, normalizedIndex)); //光柱的位置 特效的索引

                vh.SetUIVertex(vertex, i);
            }
        }

        /// <summary>
        /// 播放特效
        /// </summary>
        public void Play()
        {
            Player.Play();
        }

        /// <summary>
        /// 暂停特效
        /// </summary>
        public void Stop()
        {
            Player.Stop();
        }

        /// <summary>
        /// 手动设置数据
        /// </summary>
        protected override void SetDirty()
        {
            ParaTex.RegisterMaterial(TargetGraphic.material);
            ParaTex.SetData(this, 0, EffectFactor); //param1.x:特效播放的进度
            ParaTex.SetData(this, 1, Width); //param1.y:流光的粗细
            ParaTex.SetData(this, 2, Softness); //param1.z:流光的渐变的软边
            ParaTex.SetData(this, 3, Brightness); //param1.w:流光的亮度
            ParaTex.SetData(this, 4, Gloss); //param2.x:流光的曝光度

            //Debug.Log($"{effectFactor},{width},{softness},{brightness},{gloss}");
            //旋转不一样还要重新设置顶点数据
            if (!Mathf.Approximately(lastRotation, Rotation) && TargetGraphic)
            {
                lastRotation = Rotation;
                TargetGraphic.SetVerticesDirty();
            }
        }
    }
}