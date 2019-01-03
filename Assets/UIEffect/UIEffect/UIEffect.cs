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

        /// <summary>
        /// 特效的影响程度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("特效的影响程度")]
        private float effectFactor = 1;

        /// <summary>
        /// 颜色的影响程度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("颜色的影响程度")]
        private float colorFactor = 1;

        /// <summary>
        /// 模糊的影响程度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("模糊的影响程度")]
        private float blurFactor = 1;

        /// <summary>
        /// 特效的模式
        /// </summary>
        [SerializeField, Tooltip("特效的模式")]
        private EffectMode effectMode;

        /// <summary>
        /// 颜色的模式
        /// </summary>
        [SerializeField, Tooltip("颜色的模式")]
        private ColorMode colorMode;

        /// <summary>
        /// 模糊的模式
        /// </summary>
        [SerializeField, Tooltip("模糊的模式")]
        private BlurMode blurMode;

        [SerializeField, Tooltip("进阶的模糊")]
        private bool advanceBlur = false;

        /// <summary>
        /// 特效的播放比例
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set
            {
                value = Mathf.Clamp01(value);
                if (!Mathf.Approximately(effectFactor, value))
                {
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 颜色的影响程度
        /// </summary>
        public float ColorFactor
        {
            get => colorFactor;
            set
            {
                value = Mathf.Clamp01(value);
                if (!Mathf.Approximately(colorFactor, value))
                {
                    colorFactor = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 模糊的影响程度
        /// </summary>
        public float BlurFactor
        {
            get => blurFactor;
            set
            {
                value = Mathf.Clamp01(value);
                if (!Mathf.Approximately(blurFactor, value))
                {
                    blurFactor = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效的模式
        /// </summary>
        public EffectMode EffectMode => effectMode;

        /// <summary>
        /// 颜色的模式
        /// </summary>
        public ColorMode ColorMode => colorMode;

        /// <summary>
        /// 模糊的模式
        /// </summary>
        public BlurMode BlurMode => blurMode;

        /// <summary>
        /// 特效的颜色
        /// </summary>
        public Color EffectColor
        {
            get => graphic.color;
            set
            {
                if (graphic.color != value)
                {
                    graphic.color = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效参数图
        /// </summary>
        public override ParameterTexture ParaTex => paraTex;

        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled)
            {
                return;
            }

            if (BlurMode != BlurMode.None && advanceBlur)
            {
                vh.GetUIVertexStream(tempVerts);
                vh.Clear();

                var count = tempVerts.Count;

                //字要单独分开计算,图片一次性计算
                //为什么是6,因为矩形是两个三角形,六个顶点组成
                int bundleSize = TargetGraphic is Text ? 6 : count;
                Rect posBounds = default;//位置捆
                Rect uvBounds = default;//UV捆
                Vector3 size = default;//尺寸
                Vector3 tPos = default;//顶点位置
                Vector3 tUV = default;//顶点UV
                float expand = (float)BlurMode * 6 * 2;//模糊模式用

                for (int i = 0; i < count; i += bundleSize)
                {
                    //计算最小矩形框
                    GetBounds(tempVerts, i, bundleSize, ref posBounds, ref uvBounds, true);

                    //打包UV Mask
                    Vector2 uvMask = new Vector2(Packer.ToFloat(uvBounds.xMin, uvBounds.yMin), Packer.ToFloat(uvBounds.xMax, uvBounds.yMax));

                    //计算多少个矩形
                    for(int j=0;j<bundleSize;j+=6)
                    {
                        Vector3 cornerPos1 = tempVerts[i + j + 1].position;//第一个三角形
                        Vector3 cornerPos2 = tempVerts[i + j + 4].position;//第二个三角形

                    }
                }
            }

        }

        /// <summary>
        /// 计算最小矩形框
        /// </summary>
        private static void GetBounds(List<UIVertex> vertexs, int start, int count
            , ref Rect posBounds, ref Rect uvBounds, bool global)
        {
            Vector2 minPos = new Vector2(float.MaxValue, float.MaxValue);
            Vector2 maxPos = new Vector2(float.MinValue, float.MinValue);
            Vector2 minUV = new Vector2(float.MaxValue, float.MaxValue);
            Vector2 maxUV = new Vector2(float.MinValue, float.MinValue);

            for (int i = start; i < start + count; i++)
            {
                UIVertex vt = vertexs[i];

                Vector2 uv = vt.uv0;
                Vector3 pos = vt.position;

                //正常的图片都是N个矩形组成,所以这样算没事
                if (minPos.x >= pos.x && minPos.y >= pos.y)
                {//左下角
                    minPos = pos;
                }
                else if (maxPos.x <= pos.x && maxPos.y <= pos.y)
                {//右上角
                    maxPos = pos;
                }

                if (minUV.x >= uv.x && minUV.y >= uv.y)
                {//左下角
                    minUV = uv;
                }
                else if (maxUV.x <= uv.x && maxUV.y <= uv.y)
                {//右上角
                    maxUV = uv;
                }
            }

            //顶点往内缩一圈,检测出边缘
            posBounds.Set(minPos.x + 0.001f, minPos.y + 0.001f, maxPos.x - minPos.x - 0.002f, maxPos.y - minPos.y - 0.002f);
            //UV不用变
            uvBounds.Set(minUV.x, minUV.y, maxUV.x - minUV.x, maxUV.y - minUV.y);
        }
    }
}