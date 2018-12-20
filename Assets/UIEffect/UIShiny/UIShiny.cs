using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using UnityEngine;
using UnityEngine.UI;
using Vector2 = UnityEngine.Vector2;

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
        [SerializeField, Range(0, 1), Tooltip("Location for shiny effect")]
        private float effectFactor = 0;

        /// <summary>
        /// 流光的宽度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("Width for shiny effect")]
        private float width = 0.25f;

        /// <summary>
        /// 流光的旋转
        /// </summary>
        [SerializeField, Range(-180, 180), Tooltip("Width for shiny effect")]
        private float rotation = 0;

        /// <summary>
        /// 流光的渐变软边
        /// </summary>
        [SerializeField, Range(0.01f, 1), Tooltip("Softness for shiny effect")]
        private float softness = 1f;

        /// <summary>
        /// 流光的亮度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("Brightness for shiny effect")]
        private float brightness = 1f;

        /// <summary>
        /// 流光的曝光度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("Highlight")]
        private float gloss = 1;

        /// <summary>
        /// 流光的区域
        /// </summary>
        [SerializeField, Tooltip("The area for effect")]
        protected EffectArea effectArea;

        /// <summary>
        /// 流光的播放器
        /// </summary>
        [SerializeField] protected EffectPlayer player;

        /// <summary>
        /// 特效的播放进度 0~1
        /// 如果set 的值过于近似也不会有效果
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set
            {
                value = Mathf.Clamp01(value);
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
                value = Mathf.Clamp01(value);
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
                value = Mathf.Clamp(value, 0.01f, 1f);
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
                value = Mathf.Clamp01(value);
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
                value = Mathf.Clamp01(value);
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
        /// 特效显示的区域
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
        /// 是否播放特效
        /// </summary>
        public bool Play
        {
            get => player.play;
            set => player.play = value;
        }

        /// <summary>
        /// 特效是否循环
        /// </summary>
        public bool Loop
        {
            get => player.loop;
            set => player.loop = value;
        }

        /// <summary>
        /// 特效播放多久
        /// </summary>
        public float Duration
        {
            get => player.duration;
            set => player.duration = Mathf.Max(value, 0.01f);
        }

        /// <summary>
        /// 特效播放 延迟多久再次循环播放
        /// </summary>
        public float LoopDelay
        {
            get => player.loopDelay;
            set => player.loopDelay = Mathf.Max(value, 0);
        }

        /// <summary>
        /// 特效的播放时间方式
        /// </summary>
        public AnimatorUpdateMode UpdateMode
        {
            get => player.updateMode;
            set => player.updateMode = value;
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
            player.OnEnable(f => effectFactor = f);
        }

        /// <summary>
        /// 注销事件
        /// </summary>
        protected override void OnDisable()
        {
            base.OnDisable();
            player.OnDisable();
        }

        /// <summary>
        /// 修改mesh 的时候
        /// </summary>
        /// <param name="vh"></param>
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled) return;

            float normalizedIndex = paraTex.GetNormalizedIndex(this); //特效的索引

            Rect rect = effectArea.GetEffectArea(vh, graphic);

            //计算角度
            float rad = rotation * Mathf.Deg2Rad;
            Vector2 dir = new Vector2(Mathf.Cos(rad), Mathf.Sin(rad));
            dir.x *= rect.height / rect.width; //因为rect的宽高问题 角度需要重新算
            dir = dir.normalized;

            //是否是text 流光组件用
            bool effectEachCharacter = graphic is Text && effectArea == EffectArea.Character;

            UIVertex vertex = default;
            Matrix2x3 localMatrix = new Matrix2x3(rect, dir.x, dir.y);

            for (int i = 0; i < vh.currentIndexCount; i++)
            {
                vh.PopulateUIVertex(ref vertex, i);

                //根据矩阵标准化顶点位置
                var vertexPos = effectEachCharacter
                    ? splitedCharacterPosition[i % 4]
                    : (Vector2) vertex.position;
                var normalizedPos = localMatrix * vertexPos;

                vertex.uv0 = new Vector2(
                    Packer.ToFloat(vertex.uv0.x,vertex.uv0.y), //原来的UV
                    Packer.ToFloat(normalizedPos.y,normalizedIndex)); //光柱的位置 特效的索引

                vh.SetUIVertex(vertex, i);
            }
        }
    }
}