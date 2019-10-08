using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using UnityEngine;
using UnityEngine.Events;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Image Effects/Cinematic/Tonemapping and Color Grading")]
[ImageEffectAllowedInSceneView]
public class LensFlare_TonemappingColorGrading : MonoBehaviour
{
#if UNITY_EDITOR
    public UnityAction<RenderTexture> onFrameEndEditorOnly;

    [SerializeField] private ComputeShader histogramComputeShader;

    public ComputeShader HistogramComputeShader
    {
        get
        {
            if (histogramComputeShader == null)
            {
                histogramComputeShader = Resources.Load<ComputeShader>("HistogramCompute");
            }

            return histogramComputeShader;
        }
    }

    [SerializeField] private Shader histogramShader;

    public Shader HistogramShader
    {
        get
        {
            if (histogramShader = null)
            {
                histogramShader = Shader.Find("HCS/TonemappingColorGrading");
            }

            return histogramShader;
        }
    }

    [SerializeField] public bool histogramRefreshOnPlay = false;

#endif

    #region Attributes

    [AttributeUsage(AttributeTargets.Field)]
    public class SettingGroup : Attribute
    {
    }

    public class IndentGroup : PropertyAttribute
    {
    }

    public class ChannelMixer : PropertyAttribute
    {
    }

    public class ColorWheelGroup : PropertyAttribute
    {
        public int minSizePerWheel = 60;
        public int maxSizePerWheel = 150;

        public ColorWheelGroup(int _min, int _max)
        {
            minSizePerWheel = _min;
            maxSizePerWheel = _max;
        }
    }

    public class Curve : PropertyAttribute
    {
        public Color color = Color.white;

        public Curve()
        {
        }

        //不能用struct   因为Attribute 不支持 struct
        public Curve(float r, float g, float b, float a)
        {
            color = new Color(r, g, b, a);
        }
    }

    #endregion

    #region Settings

    [SerializeField]
    public struct EyeAdaptationSettings
    {
        public bool enabled;

        [Min(0f), Tooltip("中点调整")] public float middleGrey;

        [Tooltip("尽可能最高的曝光值。调整这个值来修改你最亮的区域。")] public float min;

        [Tooltip("尽可能的最低曝光值。调整此值以修改级别中最暗的区域。")]
        public float max;

        [Min(0f), Tooltip("线性适应速度。越高越快。")] public float speed;

        [Tooltip("在游戏视图中显示亮度对象。")] public bool showDebug;

        public static EyeAdaptationSettings defaultSettings =>
            new EyeAdaptationSettings()
            {
                enabled = false,
                showDebug = false,
                middleGrey = 0.5f,
                min = -3f,
                max = 3f,
                speed = 1.5f
            };
    }

    public enum Tonemapper
    {
        ACES,
        Curve,
        Hable,
        HejlDawson,
        Photographic,
        Reinhard,
        Neutral
    }

    [Serializable]
    public struct TonemappingSettings
    {
        public bool enabled;

        [Tooltip("要使用的色调映射技术。推荐使用aces。")] public Tonemapper tonemapper;

        [Min(0f), Tooltip("调整场景的整体曝光。")] public float exposure;

        [Tooltip("自定义色调映射曲线。")] public AnimationCurve curve;

        // 挡级设置
        [Range(-0.1f, 0.1f)] public float neutralBlackIn;

        [Range(1f, 20f)] public float neutralWhiteIn;

        [Range(-0.09f, 0.1f)] public float neutralBlackOut;

        [Range(1f, 19f)] public float neutralWhiteOut;

        [Range(0.1f, 20f)] public float neutralWhiteLevel;

        [Range(1f, 10f)] public float neutralWhiteClip;


        public static TonemappingSettings defaultSettings
        {
            get
            {
                return new TonemappingSettings
                {
                    enabled = false,
                    tonemapper = Tonemapper.Neutral,
                    exposure = 1f,
                    //TODO://curve = CurvesSettings.defaultCurve,
                    neutralBlackIn = 0.02f,
                    neutralWhiteIn = 10f,
                    neutralBlackOut = 0f,
                    neutralWhiteOut = 10f,
                    neutralWhiteLevel = 5.3f,
                    neutralWhiteClip = 10f
                };
            }
        }
    }

    #endregion
}