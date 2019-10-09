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
    public class SettingsGroup : Attribute
    {
    }

    public class IndentedGroup : PropertyAttribute
    {
    }

    public class ChannelMixer : PropertyAttribute
    {
    }

    public class ColorWheelGroup : PropertyAttribute
    {
        public int minSizePerWheel = 60;
        public int maxSizePerWheel = 150;

        public ColorWheelGroup()
        {
        }

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

    [Serializable]
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
            new EyeAdaptationSettings
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
                    curve = CurvesSettings.defaultCurve,
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

    [Serializable]
    public struct LUTSettings
    {
        public bool enabled;

        [Tooltip("自定义查找的图片(格式 比如:256 x 16)")] public Texture texture;

        [Range(0f, 1f), Tooltip("Blending factor")]
        public float contribution;

        public static LUTSettings defaultSettings =>
            new LUTSettings()
            {
                enabled = false,
                texture = null,
                contribution = 1f
            };
    }


    public struct ColorWheelsSettings
    {
        [ColorUsage(false)] public Color shadows;

        [ColorUsage(false)] public Color midtones;

        [ColorUsage(false)] public Color highlights;

        public static ColorWheelsSettings defaultSettings
        {
            get
            {
                return new ColorWheelsSettings()
                {
                    shadows = Color.white,
                    midtones = Color.white,
                    highlights = Color.white
                };
            }
        }
    }

    [Serializable]
    public struct BasicsSettings
    {
        [Range(-2f, 2f), Tooltip("将白平衡设置为自定义色温。")]
        public float temperatureShift;

        [Range(-2f, 2f), Tooltip("设置白平衡以补偿绿色或洋红色调。")]
        public float tint;

        [Space, Range(-0.5f, 0.5f), Tooltip("改变所有颜色的色调。")]
        public float hue;

        [Range(0f, 2f), Tooltip("推动所有颜色的强度。")] public float saturation;

        [Range(-1f, 1f),
         Tooltip("调整饱和度，使剪裁最小化，颜色接近全饱和。")]
        public float vibrance;

        [Range(0f, 10f), Tooltip("使所有颜色变亮或变暗。")]
        public float value;

        [Space, Range(0f, 2f), Tooltip("扩展或缩小色调值的整体范围。")]
        public float contrast;

        [Range(0.01f, 5f), Tooltip("对比度增益曲线。控制曲线的陡度。")]
        public float gain;

        [Range(0.01f, 5f), Tooltip("对源应用POW函数。")]
        public float gamma;

        public static BasicsSettings defaultSettings
        {
            get
            {
                return new BasicsSettings
                {
                    temperatureShift = 0f,
                    tint = 0f,
                    contrast = 1f,
                    hue = 0f,
                    saturation = 1f,
                    value = 1f,
                    vibrance = 0f,
                    gain = 1f,
                    gamma = 1f
                };
            }
        }
    }


    [Serializable]
    public struct ChannelMixerSettings
    {
        public int currentChannel;
        public Vector3[] channels;

        public static ChannelMixerSettings defaultSettings
        {
            get
            {
                return new ChannelMixerSettings
                {
                    currentChannel = 0,
                    channels = new[]
                    {
                        new Vector3(1f, 0f, 0f),
                        new Vector3(0f, 1f, 0f),
                        new Vector3(0f, 0f, 1f)
                    }
                };
            }
        }
    }

    [Serializable]
    public struct CurvesSettings
    {
        [Curve] public AnimationCurve master;

        [Curve(1f, 0f, 0f, 1f)] public AnimationCurve red;

        [Curve(0f, 1f, 0f, 1f)] public AnimationCurve green;

        [Curve(0f, 1f, 1f, 1f)] public AnimationCurve blue;

        public static AnimationCurve defaultCurve
        {
            get { return new AnimationCurve(new Keyframe(0f, 0f, 1f, 1f), new Keyframe(1f, 1f, 1f, 1f)); }
        }

        public static CurvesSettings defaultSettings
        {
            get
            {
                return new CurvesSettings
                {
                    master = defaultCurve,
                    red = defaultCurve,
                    green = defaultCurve,
                    blue = defaultCurve
                };
            }
        }
    }

    public enum ColorGradingPrecision
    {
        Normal = 16,
        High = 32
    }

    [Serializable]
    public struct ColorGradingSettings
    {
        public bool enabled;

        [Tooltip(
            "LUT 精度. \"Normal\" 用 256x16, \"High\" 用 1024x32. 建议使用 \"Normal\"在手机上")]
        public ColorGradingPrecision precision;

        [Space, ColorWheelGroup] public ColorWheelsSettings colorWheels;

        [Space, IndentedGroup] public BasicsSettings basics;

        [Space, ChannelMixer] public ChannelMixerSettings channelMixer;

        [Space, IndentedGroup] public CurvesSettings curves;

        [Space, Tooltip("使用抖动来尝试解决最小化黑暗区域中的色带。")]
        public bool useDithering;

        [Tooltip("在GameView的左上角显示生成的LUT。")] public bool showDebug;

        public static ColorGradingSettings defaultSettings
        {
            get
            {
                return new ColorGradingSettings
                {
                    enabled = false,
                    useDithering = false,
                    showDebug = false,
                    precision = ColorGradingPrecision.Normal,
                    colorWheels = ColorWheelsSettings.defaultSettings,
                    basics = BasicsSettings.defaultSettings,
                    channelMixer = ChannelMixerSettings.defaultSettings,
                    curves = CurvesSettings.defaultSettings
                };
            }
        }

        internal void Reset()
        {
            curves = CurvesSettings.defaultSettings;
        }
    }

    [SerializeField, SettingsGroup]
    private EyeAdaptationSettings _eyeAdaptation = EyeAdaptationSettings.defaultSettings;

    public EyeAdaptationSettings EyeAdaptation
    {
        get { return _eyeAdaptation; }
        set { _eyeAdaptation = value; }
    }

    [SerializeField, SettingsGroup] private TonemappingSettings _tonemapping = TonemappingSettings.defaultSettings;

    public TonemappingSettings Tonemapping
    {
        get { return _tonemapping; }
        set
        {
            _tonemapping = value;
            SetTonemapperDirty();
        }
    }

    [SerializeField, SettingsGroup] private ColorGradingSettings _colorGrading = ColorGradingSettings.defaultSettings;

    public ColorGradingSettings ColorGrading
    {
        get { return _colorGrading; }
        set
        {
            _colorGrading = value;
            SetDirty();
        }
    }

    [SerializeField, SettingsGroup] private LUTSettings _lut = LUTSettings.defaultSettings;

    public LUTSettings Lut
    {
        get { return _lut; }
        set { _lut = value; }
    }

    #endregion

    private Texture2D _identityLut;
    private RenderTexture _internalLut;
    private Texture2D _curveTexture;
    private Texture2D _tonemapperCurve;
    private float _tonemapperCurveRange;

    private Texture2D IdentityLut
    {
        get
        {
            if (_identityLut == null || _identityLut.height != lutSize)
            {
                DestroyImmediate(_identityLut);
                _identityLut = GenerateIdentityLut(lutSize);
            }

            return _identityLut;
        }
    }

    private RenderTexture InternalLutRt
    {
        get
        {
            if (_internalLut == null || !_internalLut.IsCreated() || _internalLut.height != lutSize)
            {
                DestroyImmediate(_internalLut);
                _internalLut = new RenderTexture(lutSize * lutSize, lutSize, 0, RenderTextureFormat.ARGB32)
                {
                    name = "Internal LUT",
                    filterMode = FilterMode.Bilinear,
                    anisoLevel = 0,
                    hideFlags = HideFlags.DontSave
                };
            }

            return _internalLut;
        }
    }

    private Texture2D CurveTexture
    {
        get
        {
            if (_curveTexture == null)
            {
                _curveTexture = new Texture2D(256, 1, TextureFormat.ARGB32, false, true)
                {
                    name = "Curve texture",
                    wrapMode = TextureWrapMode.Clamp,
                    filterMode = FilterMode.Bilinear,
                    anisoLevel = 0,
                    hideFlags = HideFlags.DontSave
                };
            }

            return _curveTexture;
        }
    }

    private Texture2D TonemapperCurve
    {
        get
        {
            if (_tonemapperCurve == null)
            {
                TextureFormat format = TextureFormat.RGB24;
                if (SystemInfo.SupportsTextureFormat(TextureFormat.RFloat))
                    format = TextureFormat.RFloat;
                else if (SystemInfo.SupportsTextureFormat(TextureFormat.RHalf))
                    format = TextureFormat.RHalf;

                _tonemapperCurve = new Texture2D(256, 1, format, false, true)
                {
                    name = "Tonemapper curve texture",
                    wrapMode = TextureWrapMode.Clamp,
                    filterMode = FilterMode.Bilinear,
                    anisoLevel = 0,
                    hideFlags = HideFlags.DontSave
                };
            }

            return _tonemapperCurve;
        }
    }

    [SerializeField] private Shader _shader;

    public Shader Shader
    {
        get
        {
            if (_shader == null)
                _shader = Shader.Find("HCS/TonemappingColorGrading");

            return _shader;
        }
    }

    private Material _material;

    public Material Material
    {
        get
        {
            if (_material == null)
                _material = LensFlare_ImageEffectHelper.CheckShaderAndCreateMaterial(Shader);

            return _material;
        }
    }

    public bool IsGammaColorSpace
    {
        get { return QualitySettings.activeColorSpace == ColorSpace.Gamma; }
    }

    public int lutSize
    {
        get { return (int) ColorGrading.precision; }
    }

    private enum Pass
    {
        LutGen,
        AdaptationLog,
        AdaptationExpBlend,
        AdaptationExp,
        TonemappingOff,
        TonemappingACES,
        TonemappingCurve,
        TonemappingHable,
        TonemappingHejlDawson,
        TonemappingPhotographic,
        TonemappingReinhard,
        TonemappingNeutral,
        AdaptationDebug
    }

    public bool validRenderTextureFormat { get; private set; }
    public bool validUserLutSize { get; private set; }

    private bool dirty = true;
    private bool tonemapperDirty = true;

    private RenderTexture smallAdaptiveRt;
    private RenderTextureFormat adaptiveRtFormat;

    private int adaptationSpeedID;
    private int middleGreyID;
    private int adaptationMinID;
    private int adaptationMaxID;
    private int lumTexID;
    private int toneCurveRangeID;
    private int toneCurveID;
    private int exposureID;
    private int neutralTonemapperParams1ID;
    private int neutralTonemapperParams2ID;
    private int whiteBalanceID;
    private int liftID;
    private int gammaID;
    private int gainID;
    private int contrastGainGammaID;
    private int vibranceID;
    private int HSVID;
    private int channelMixerRedID;
    private int channelMixerGreenID;
    private int channelMixerBlueID;
    private int curveTexID;
    private int internalLutTexID;
    private int internalLutParamsID;
    private int userLutTexID;
    private int userLutParamsID;

    public void SetDirty()
    {
        dirty = true;
    }

    public void SetTonemapperDirty()
    {
        tonemapperDirty = true;
    }

    private void Awake()
    {
        adaptationSpeedID = Shader.PropertyToID("_AdaptationSpeed");
        middleGreyID = Shader.PropertyToID("_MiddleGrey");
        adaptationMinID = Shader.PropertyToID("_AdaptationMin");
        adaptationMaxID = Shader.PropertyToID("_AdaptationMax");
        lumTexID = Shader.PropertyToID("_LumTex");
        toneCurveRangeID = Shader.PropertyToID("_ToneCurveRange");
        toneCurveID = Shader.PropertyToID("_ToneCurve");
        exposureID = Shader.PropertyToID("_Exposure");
        neutralTonemapperParams1ID = Shader.PropertyToID("_NeutralTonemapperParams1");
        neutralTonemapperParams2ID = Shader.PropertyToID("_NeutralTonemapperParams2");
        whiteBalanceID = Shader.PropertyToID("_WhiteBalance");
        liftID = Shader.PropertyToID("_Lift");
        gammaID = Shader.PropertyToID("_Gamma");
        gainID = Shader.PropertyToID("_Gain");
        contrastGainGammaID = Shader.PropertyToID("_ContrastGainGamma");
        vibranceID = Shader.PropertyToID("_Vibrance");
        HSVID = Shader.PropertyToID("_HSV");
        channelMixerRedID = Shader.PropertyToID("_ChannelMixerRed");
        channelMixerGreenID = Shader.PropertyToID("_ChannelMixerGreen");
        channelMixerBlueID = Shader.PropertyToID("_ChannelMixerBlue");
        curveTexID = Shader.PropertyToID("_CurveTex");
        internalLutTexID = Shader.PropertyToID("_InternalLutTex");
        internalLutParamsID = Shader.PropertyToID("_InternalLutParams");
        userLutTexID = Shader.PropertyToID("_UserLutTex");
        userLutParamsID = Shader.PropertyToID("_UserLutParams");
    }

    private void OnEnable()
    {
        if (!LensFlare_ImageEffectHelper.IsSupported(Shader, false, true, this))
        {
            enabled = false;
            return;
        }

        SetDirty();
        SetTonemapperDirty();
    }

    private void OnDisable()
    {
        if (Material != null)
            DestroyImmediate(Material);

        if (IdentityLut != null)
            DestroyImmediate(IdentityLut);

        if (InternalLutRt != null)
            DestroyImmediate(InternalLutRt);

        if (smallAdaptiveRt != null)
            DestroyImmediate(smallAdaptiveRt);

        if (CurveTexture != null)
            DestroyImmediate(CurveTexture);

        if (TonemapperCurve != null)
            DestroyImmediate(TonemapperCurve);

        _material = null;
        _identityLut = null;
        _internalLut = null;
        smallAdaptiveRt = null;
        _curveTexture = null;
        _tonemapperCurve = null;
    }

    private void OnValidate()
    {
        SetDirty();
        SetTonemapperDirty();
    }

    private static Texture2D GenerateIdentityLut(int dim)
    {
        Color[] newC = new Color[dim * dim * dim];
        float oneOverDim = 1f / ((float) dim - 1f);

        for (int i = 0; i < dim; i++)
        for (int j = 0; j < dim; j++)
        for (int k = 0; k < dim; k++)
            newC[i + (j * dim) + (k * dim * dim)] =
                new Color((float) i * oneOverDim, Mathf.Abs((float) j * oneOverDim), Mathf.Abs((float) k * oneOverDim),
                    1f);

        Texture2D tex2D = new Texture2D(dim * dim, dim, TextureFormat.RGB24, false, false)
        {
            name = "Identity Lut",
            filterMode = FilterMode.Bilinear,
            anisoLevel = 0,
            hideFlags = HideFlags.DontSave
        };
        tex2D.SetPixels(newC);
        tex2D.Apply();

        return tex2D;
    }

    //Judd等人的标准光源色度分析模型。
    // http://en.wikipedia.org/wiki/Standard_illuminant#Illuminant_series_D
    //稍微修改一下，用D65白点（X=0.31271，Y=0.32902）调整。
    private float StandardIlluminantY(float x)
    {
        return 2.87f * x - 3f * x * x - 0.27509507f;
    }

    // CIE xy 色度 to CAT02 LMS.
    // http://en.wikipedia.org/wiki/LMS_color_space#CAT02
    private Vector3 CIExyToLMS(float x, float y)
    {
        float Y = 1f;
        float X = Y * x / y;
        float Z = Y * (1f - x - y) / y;

        float L = 0.7328f * X + 0.4296f * Y - 0.1624f * Z;
        float M = -0.7036f * X + 1.6975f * Y + 0.0061f * Z;
        float S = 0.0030f * X + 0.0136f * Y + 0.9834f * Z;

        return new Vector3(L, M, S);
    }

    //得到LMS空间下白平衡
    private Vector3 GetWhiteBalance()
    {
        float t1 = ColorGrading.basics.temperatureShift;
        float t2 = ColorGrading.basics.tint;

        // 参考白点的CIE xy
        // 注意: 0.31271 = x 值 在 D65 白点
        float x = 0.31271f - t1 * (t1 < 0f ? 0.1f : 0.05f);
        float y = StandardIlluminantY(x) + t2 * 0.05f;

        // 计算lms空间中的系数。
        Vector3 w1 = new Vector3(0.949237f, 1.03542f, 1.08728f); // D65 白点
        Vector3 w2 = CIExyToLMS(x, y);
        return new Vector3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);
    }

    private static Color NormalizeColor(Color c)
    {
        float sum = (c.r + c.g + c.b) / 3f;

        if (Mathf.Approximately(sum, 0f))
            return new Color(1f, 1f, 1f, 1f);

        return new Color()
        {
            r = c.r / sum,
            g = c.g / sum,
            b = c.b / sum,
            a = 1f
        };
    }


    private void GenCurveTexture()
    {
        AnimationCurve master = ColorGrading.curves.master;
        AnimationCurve red = ColorGrading.curves.red;
        AnimationCurve green = ColorGrading.curves.green;
        AnimationCurve blue = ColorGrading.curves.blue;

        Color[] pixels = new Color[256];

        for (float i = 0f; i <= 1f; i += 1f / 255f)
        {
            float m = Mathf.Clamp(master.Evaluate(i), 0f, 1f);
            float r = Mathf.Clamp(red.Evaluate(i), 0f, 1f);
            float g = Mathf.Clamp(green.Evaluate(i), 0f, 1f);
            float b = Mathf.Clamp(blue.Evaluate(i), 0f, 1f);
            pixels[(int)Mathf.Floor(i * 255f)] = new Color(r, g, b, m);
        }

        CurveTexture.SetPixels(pixels);
        CurveTexture.Apply();
    }

    private bool CheckUserLut()
    {
        validUserLutSize = Lut.texture.height == (int)Mathf.Sqrt(Lut.texture.width);
        return validUserLutSize;
    }

    private bool CheckSmallAdaptiveRt()
    {
        if (smallAdaptiveRt != null)
            return false;

        adaptiveRtFormat = RenderTextureFormat.ARGBHalf;

        if (SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.RGHalf))
            adaptiveRtFormat = RenderTextureFormat.RGHalf;

        smallAdaptiveRt = new RenderTexture(1, 1, 0, adaptiveRtFormat) {hideFlags = HideFlags.DontSave};

        return true;
    }

    private void OnGUI()
    {
        if (Event.current.type != EventType.Repaint)
            return;

        int yoffset = 0;

        // Color grading debug
        if (InternalLutRt != null && ColorGrading.enabled && ColorGrading.showDebug)
        {
            Graphics.DrawTexture(new Rect(0f, yoffset, lutSize * lutSize, lutSize), InternalLutRt);
            yoffset += lutSize;
        }

        // Eye Adaptation debug
        if (smallAdaptiveRt != null && EyeAdaptation.enabled && EyeAdaptation.showDebug)
        {
            Material.SetPass((int)Pass.AdaptationDebug);
            Graphics.DrawTexture(new Rect(0f, yoffset, 256, 16), smallAdaptiveRt, Material);
        }
    }

    public Texture2D BakeLUT()
    {
        Texture2D lut = new Texture2D(InternalLutRt.width, InternalLutRt.height, TextureFormat.RGB24, false, true);
        RenderTexture.active = InternalLutRt;
        lut.ReadPixels(new Rect(0f, 0f, lut.width, lut.height), 0, 0);
        RenderTexture.active = null;
        return lut;
    }

    private RenderTexture[] m_AdaptRts = null;
}