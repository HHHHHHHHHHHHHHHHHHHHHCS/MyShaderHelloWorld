using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// UI外轮廓用
    /// </summary>
    [RequireComponent(typeof(Graphics))]
    public class UIShadow : Shadow, IParameterTexture
    {
        /// <summary>
        /// 这个组件上挂了几个效果
        /// </summary>
        private static readonly List<UIShadow> tmpShadows = new List<UIShadow>();

        /// <summary>
        /// UI的顶点数据保存用
        /// </summary>
        private static readonly List<UIVertex> vertexs = new List<UIVertex>();

        /// <summary>
        /// 外轮廓的模糊程度
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("外轮廓的模糊程度")]
        private float blurFactor = 1;

        /// <summary>
        /// 轮廓的效果
        /// </summary>
        [SerializeField, Tooltip("轮廓的效果")] private ShadowStyle style = ShadowStyle.Shadow;

        /// <summary>
        /// ui常见的特效
        /// </summary>
        private UIEffect uieffect;

        /// <summary>
        /// 原来的无轮廓的顶点总数
        /// </summary>
        private int graphicVertexCount;

        /// <summary>
        /// 外轮廓的模糊程度
        /// </summary>
        public float BlurFactor
        {
            get => blurFactor;
            set
            {
                if (blurFactor != value)
                {
                    blurFactor = Mathf.Clamp(value, 0, 2);
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 轮廓的效果
        /// </summary>
        public ShadowStyle Style
        {
            get => style;
            set
            {
                if (style != value)
                {
                    style = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效参数图索引
        /// </summary>
        public int ParameterIndex { get; set; }

        /// <summary>
        /// 特效的参数图
        /// </summary>
        public ParameterTexture ParaTex { get; private set; }

        /// <summary>
        /// 注册一些参数和效果
        /// </summary>
        protected override void OnEnable()
        {
            base.OnEnable();

            uieffect = GetComponent<UIEffect>();
            if (uieffect)
            {
                ParaTex = uieffect.ParaTex;
                ParaTex.Register(this);
            }
        }

        /// <summary>
        /// 注销参数和效果
        /// </summary>
        protected override void OnDisable()
        {
            base.OnDisable();

            uieffect = null;
            if (ParaTex != null)
            {
                ParaTex.Unregister(this);
                ParaTex = null;
            }
        }

        /// <summary>
        /// 改变Mesh,制作效果
        /// </summary>
        public override void ModifyMesh(VertexHelper vh)
        {
            if (!isActiveAndEnabled || vh.currentIndexCount <= 0 || style == ShadowStyle.None)
            {
                return;
            }

            //获得全部的 顶点和UI外轮廓效果
            vh.GetUIVertexStream(vertexs);
            GetComponents(tmpShadows);

            //设置顶点总数,通知其他的UIShadow改变顶点总数
            foreach (var item in tmpShadows)
            {
                if (item.isActiveAndEnabled)
                {
                    if (item == this)
                    {
                        foreach (var tmp in tmpShadows)
                        {
                            tmp.graphicVertexCount = vertexs.Count;
                        }
                    }

                    break;
                }
            }

            tmpShadows.Clear();

            //制作阴影顶点
            uieffect = uieffect ?? GetComponent<UIEffect>();
            //多个UIShadow,要计算要改变的顶点
            var start = vertexs.Count - graphicVertexCount;
            var end = vertexs.Count;

            if (ParaTex != null && uieffect && uieffect.isActiveAndEnabled)
            {
                ParaTex.SetData(this, 0, uieffect.EffectFactor); //param1.x 特效的影响度
                ParaTex.SetData(this, 1, 255); //param1.y 颜色的影响度
                ParaTex.SetData(this, 2, BlurFactor); //param1.z 模糊的影响度
            }

            MyApplyShadow(vertexs, effectColor, ref start, ref end, effectDistance, style, useGraphicAlpha);

            //清除原来的顶点 载入加了阴影后的顶点 清除缓存顶点list
            vh.Clear();
            vh.AddUIVertexTriangleStream(vertexs);
            vertexs.Clear();
        }

        /// <summary>
        /// 使用阴影效果
        /// </summary>
        /// <param name="verts">顶点数据</param>
        /// <param name="color">轮廓颜色</param>
        /// <param name="start">原来的起始顶点</param>
        /// <param name="end">原来的结束顶点</param>
        /// <param name="effectDistance">轮廓位移</param>
        /// <param name="style">轮廓的效果</param>
        /// <param name="useAlpha">是否使用图片的Alpha</param>
        private void MyApplyShadow(List<UIVertex> verts, Color color
            , ref int start, ref int end
            , Vector2 effectDistance, ShadowStyle style, bool useAlpha)
        {
            //没有效果,或者是透明的感觉 直接不显示
            if (style == ShadowStyle.None || color.a < 0)
            {
                return;
            }

            //添加最基础的阴影轮廓
            MyApplyShadowZeroAlloc(verts, color, ref start, ref end
                , effectDistance.x, effectDistance.y, useAlpha);

            if (style == ShadowStyle.Shadow3)
            {
                //如果是 普通阴影 效果
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , effectDistance.x, 0, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , 0, effectDistance.y, useAlpha);
            }
            else if (style == ShadowStyle.Outline)
            {
                //如果是普通的外轮廓效果
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , effectDistance.x, -effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , -effectDistance.x, effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , -effectDistance.x, -effectDistance.y, useAlpha);
            }
            else if (style == ShadowStyle.Outline8)
            {
                //8次外轮廓
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , effectDistance.x, -effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , -effectDistance.x, effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , -effectDistance.x, -effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , -effectDistance.x, 0, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , 0, -effectDistance.y, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , effectDistance.x, 0, useAlpha);
                MyApplyShadowZeroAlloc(vertexs, color, ref start, ref end
                    , 0, effectDistance.y, useAlpha);
            }
        }

        /// <summary>
        /// 添加顶点阴影
        /// </summary>
        /// <param name="verts">顶点数据</param>
        /// <param name="color">轮廓颜色</param>
        /// <param name="start">原来的起始顶点</param>
        /// <param name="end">原来的结束顶点</param>
        /// <param name="xOffset">x的偏移</param>
        /// /// <param name="yOffset">y的偏移</param>
        /// <param name="useAlpha">是否使用图片的Alpha</param>
        private void MyApplyShadowZeroAlloc(List<UIVertex> verts, Color color
            , ref int start, ref int end
            , float xOffset, float yOffset, bool useAlpha)
        {
            int count = end - start;//要修改的顶点数量
            var needCapacity = verts.Count + count;//需要的容量
            if (verts.Capacity < needCapacity)
            {
                verts.Capacity = needCapacity;
            }

            //在UV中的索引
            float normalizeedIndex = ParaTex != null && uieffect && uieffect.isActiveAndEnabled
                ? ParaTex.GetNormalizedIndex(this)
                : -1;

            //添加扩充的顶点
            UIVertex vt = default;
            for (int i = 0; i < count; i++)
            {
                verts.Add(vt);
            }

            //把原来的顶点往后挪动,要改变的放前面
            //用倒序,不然可能会覆盖前面的
            for (int i = verts.Count - 1; i >= count; i--)
            {
                verts[i] = verts[i - count];
            }

            //把前挪的轮廓顶点做处理
            for (int i = 0; i < count; i++)
            {
                vt = verts[i + start + count];

                Vector3 v = vt.position;
                vt.position.Set(v.x + xOffset, v.y + yOffset, v.z);

                Color vertColor = effectColor;
                vertColor.a = useAlpha ? color.a * vt.color.a / 255 : color.a;
                vt.color = vertColor;

                if (0 <= normalizeedIndex)
                {
                    vt.uv0 = new Vector2(vt.uv0.x, normalizeedIndex);
                }

                verts[i] = vt;
            }

            //更新下一次要处理的轮廓顶点数量偏移
            start = end;
            end = verts.Count;
        }

        public void SetDirty()
        {
            if (graphic)
            {
                graphic.SetVerticesDirty();
            }
        }
    }
}