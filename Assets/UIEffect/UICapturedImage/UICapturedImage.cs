using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 艺术品图片
    /// </summary>
    public class UICapturedImage : RawImage
    {
        private const string shaderName = "UI/UICaputredImage";


        private static int copyId;//复制ID
        private static int effectId1;//特效ID1
        private static int effectId2;//特效ID2
        private static int effectFactorId;//特效进度ID
        private static int colorFactorId;//颜色进度ID
        private static CommandBuffer commandBuffer;//图片Buffer

        private RenderTexture rt;//渲染后的图片
        private RenderTargetIdentifier rtId;//图片ID

        /// <summary>
        /// 特效的播放进度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("特效的播放进度")]
        private float effectFactor = 1;

        /// <summary>
        /// 颜色播放进度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("颜色播放进度")]
        private float colorFactor = 1;

        /// <summary>
        /// 模糊的程度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("模糊的程度")]
        private float blurFactor = 1;

        /// <summary>
        /// 图片的影响模式
        /// </summary>
        [SerializeField, Tooltip("图片的影响模式")] private EffectMode effectMode = EffectMode.None;

        /// <summary>
        /// 颜色叠加模式
        /// </summary>
        [SerializeField, Tooltip("颜色叠加模式")] private ColorMode colorMode = ColorMode.Multiply;

        /// <summary>
        /// 模糊模式
        /// </summary>
        [SerializeField, Tooltip("模糊模式")] private BlurMode blurMode = BlurMode.DetailBlur;

        /// <summary>
        /// 特效的颜色
        /// </summary>
        [SerializeField, Tooltip("特效的颜色")] private Color effectColor = Color.white;

        /// <summary>
        /// 滤波采样率
        /// </summary>
        [SerializeField, Tooltip("滤波采样率")] private DesamplingRate desamplingRate = DesamplingRate.x1;

        /// <summary>
        /// 滤波去采样率
        /// </summary>
        [SerializeField, Tooltip("滤波去采样率")] private DesamplingRate reductionRate = DesamplingRate.x1;

        /// <summary>
        /// 滤波采样模式
        /// </summary>
        [SerializeField, Tooltip("滤波采样模式")] private FilterMode filterMode = FilterMode.Bilinear;

        /// <summary>
        /// 特效材质球
        /// </summary>
        [SerializeField, Tooltip("特效材质球")] private Material effectMaterial;

        /// <summary>
        /// 模糊倍率
        /// </summary>
        [Range(1, 8), SerializeField, Tooltip("模糊倍率")]
        private int blurIterations = 3;

        /// <summary>
        /// 是否填充屏幕
        /// </summary>
        [SerializeField, Tooltip("是否填充屏幕")] private bool fitToScreen = true;

        /// <summary>
        /// 是否Enable的时候就启动效果
        /// </summary>
        [SerializeField, Tooltip("是否Enable的时候就启动效果")]
        private bool captureOnEnable = false;

        /// <summary>
        /// 是否立即启动效果
        /// </summary>
        [SerializeField, Tooltip("是否立即启动效果")] private bool immediateCapturing = true;

        /// <summary>
        /// 特效的播放进度
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set => effectFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 颜色播放进度
        /// </summary>
        public float ColorFactor
        {
            get => colorFactor;
            set => colorFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 模糊的程度
        /// </summary>
        public float BlurFactor
        {
            get => blurFactor;
            set => blurFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 图片的影响模式
        /// </summary>
        public EffectMode EffectMode => effectMode;

        /// <summary>
        /// 颜色叠加模式
        /// </summary>
        public ColorMode ColorMode => colorMode;

        /// <summary>
        /// 模糊模式
        /// </summary>
        public BlurMode BlurMode => blurMode;

        /// <summary>
        /// 特效的颜色
        /// </summary>
        public Color EffectColor => effectColor;

        /// <summary>
        /// 滤波采样率
        /// </summary>
        public DesamplingRate DesamplingRate => desamplingRate;

        /// <summary>
        /// 滤波去采样率
        /// </summary>
        public DesamplingRate ReductionRate => reductionRate;

        /// <summary>
        /// 滤波采样模式
        /// </summary>
        public FilterMode FilterMode => filterMode;

        /// <summary>
        /// 特效材质球
        /// </summary>
        public Material EffectMaterial => effectMaterial;

        /// <summary>
        /// 模糊倍率
        /// </summary>
        public int BlurIterations
        {
            get => blurIterations;
            set => blurIterations = Mathf.Clamp(value, 0, 8);
        }

        /// <summary>
        /// 是否填充屏幕
        /// </summary>
        public bool FitToScreen => fitToScreen;

        /// <summary>
        /// 是否Enable的时候就启动效果
        /// </summary>
        public bool CaptureOnEnable => captureOnEnable;

        /// <summary>
        /// 是否立即启动效果
        /// </summary>
        public bool ImmediateCapturing => immediateCapturing;

#if UNITY_EDITOR
        protected override void Reset()
        {
            blurIterations = 3;
            filterMode = FilterMode.Bilinear;
            desamplingRate = DesamplingRate.x1;
            reductionRate = DesamplingRate.x1;
            base.Reset();
        }
#endif
    }
}