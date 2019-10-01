using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Image Effects/Cinematic/Bloom")]
[ImageEffectAllowedInSceneView]
public class LensFlare_Bloom : MonoBehaviour
{
    [Serializable]
    public struct Settings
    {
        [SerializeField, Tooltip("过滤此亮度强度下的像素")]
        public float threshold;


        public float ThresholdGamma
        {
            set => threshold = value;
            get => Mathf.Max(0.0f, threshold);
        }

        public float ThresholdLinear
        {
            set => threshold = Mathf.LinearToGammaSpace(value);
            get => Mathf.Max(0.0f, Mathf.GammaToLinearSpace(threshold));
        }

        [SerializeField, Range(0, 1)] [Tooltip("使低于/高于阈值之间的过渡逐渐进行")]
        public float softKnee;

        [SerializeField, Range(1, 7)] [Tooltip("以与屏幕分辨率无关的方式更改遮罩效果的范围")]
        public float radius;

        [SerializeField] [Tooltip("混合图像的因子")] public float intensity;

        [SerializeField] [Tooltip("高清,控制过滤器质量和缓冲区分辨率")]
        public bool highQuality;

        [SerializeField] [Tooltip("抗锯齿,额外的滤波器可以减少锯齿")]
        public bool antiFlicker;

        [Tooltip("增加屏幕的脏感觉")] public Texture dirtTexture;

        [Min(0f), Tooltip("脏感觉强度")] public float dirtIntensity;

        public static Settings defaultSettings
        {
            get
            {
                var settings = new Settings
                {
                    threshold = 0.9f,
                    softKnee = 0.5f,
                    radius = 2.0f,
                    intensity = 0.7f,
                    highQuality = true,
                    antiFlicker = false,
                    dirtTexture = null,
                    dirtIntensity = 2.5f
                };
                return settings;
            }
        }
    }

    #region Public Properties

    [SerializeField] public Settings settings = Settings.defaultSettings;

    #endregion

    [SerializeField, HideInInspector] private Shader shader;

    public Shader TheShader
    {
        get
        {
            if (shader == null)
            {
                const string shaderName = "HCS/LenFlare/Bloom";
                shader = Shader.Find(shaderName);
            }

            return shader;
        }
    }


    private Material material;

    public Material TheMaterial
    {
        get
        {
            if (material == null)
                material = LensFlare_ImageEffectHelper.CheckShaderAndCreateMaterial(shader);
            return material;
        }
    }


    #region Private Members

    private const int maxIterations = 16;

    private RenderTexture[] blurBuffer1 = new RenderTexture[maxIterations];
    private RenderTexture[] blurBuffer2 = new RenderTexture[maxIterations];

    private int id_threshold;
    private int id_curve;
    private int id_prefilterOffs;
    private int id_sampleScale;
    private int id_intensity;
    private int id_dirtTex;
    private int id_dirtIntensity;
    private int id_baseTex;

    private void Awake()
    {
        id_threshold = ToID("_Threshold");
        id_curve = ToID("_Curve");
        id_prefilterOffs = ToID("_PrefilterOffs");
        id_sampleScale = ToID("_SampleScale");
        id_intensity = ToID("_Intensity");
        id_dirtTex = ToID("_DirtTex");
        id_dirtIntensity = ToID("_DirtIntensity");
        id_baseTex = ToID("_BaseTex");
    }

    private int ToID(string str)
    {
        return Shader.PropertyToID(str);
    }

    private void OnEnable()
    {
        if (!LensFlare_ImageEffectHelper.IsSupported(shader, true, false, this))
            enabled = false;
    }

    private void OnDisable()
    {
        if (material != null)
            DestroyImmediate(material);

        material = null;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //手机不用HDR
        var useRGBM = Application.isMobilePlatform;

        var tw = src.width;
        var th = src.height;

        //半分辨率
        if (!settings.highQuality)
        {
            tw /= 2;
            th /= 2;
        }

        //blur buffer format
        var rtFormat = useRGBM ? RenderTextureFormat.Default : RenderTextureFormat.DefaultHDR;

        //1024=2^10 --> 10+radius-8
        var logh = Mathf.Log(th, 2) + settings.radius - 8;
        var logh_i = (int) logh;
        var iterations = Mathf.Clamp(logh_i, 1, maxIterations);

        //阀值
        var threshold = settings.ThresholdLinear;
        material.SetFloat(id_threshold, threshold);

        //卷积属性
        var knee = threshold * settings.softKnee + 1e-5f;
        var curve = new Vector3(threshold - knee, knee * 2, 0.25f / knee);
        material.SetVector(id_curve, curve);

        //抗锯齿
        var pfo = !settings.highQuality && settings.antiFlicker;
        material.SetFloat(id_prefilterOffs, pfo ? -0.5f : 0.0f);

        //强度
        material.SetFloat(id_sampleScale, 0.5f + logh - logh_i);
        material.SetFloat(id_intensity, Mathf.Max(0.0f, settings.intensity));

        //脏图
        bool useDirtTexture = false;
        if (settings.dirtTexture != null)
        {
            material.SetTexture(id_dirtTex, settings.dirtTexture);
            material.SetFloat(id_dirtIntensity, settings.dirtIntensity);
            useDirtTexture = true;
        }

        //滤波Pass
        var prefiltered = RenderTexture.GetTemporary(tw, th, 0, rtFormat);
        Graphics.Blit(src, prefiltered, material, settings.antiFlicker ? 1 : 0);

        //缩小 生成 mipmap 
        var last = prefiltered;
        for (var level = 0; level < iterations; level++)
        {
            blurBuffer1[level] =
                RenderTexture.GetTemporary(last.width / 2, last.height / 2, 0, rtFormat);
            Graphics.Blit(last, blurBuffer1[level], material, level == 0 ? (settings.antiFlicker ? 3 : 2) : 4);
            last = blurBuffer1[level];
        }

        //倒循环放大图片
        for (var level = iterations - 2; level >= 0; level--)
        {
            var baseTex = blurBuffer1[level];
            material.SetTexture(id_baseTex, baseTex);
            blurBuffer2[level] = RenderTexture.GetTemporary(baseTex.width, baseTex.height, 0, rtFormat);
            Graphics.Blit(last, blurBuffer2[level], material, settings.highQuality ? 6 : 5);
            last = blurBuffer2[level];
        }

        //最后处理
        int pass = useDirtTexture ? 9 : 7;
        pass += settings.highQuality ? 1 : 0;

        //融合
        material.SetTexture(id_baseTex, src);
        Graphics.Blit(last, dest, material, pass);

        //释放
        for (var i = 0; i < maxIterations; i++)
        {
            if (blurBuffer1[i] != null)
            {
                RenderTexture.ReleaseTemporary(blurBuffer1[i]);
            }

            if (blurBuffer2[i] != null)
            {
                RenderTexture.ReleaseTemporary(blurBuffer2[i]);
            }

            blurBuffer1[i] = null;
            blurBuffer2[i] = null;
        }

        RenderTexture.ReleaseTemporary(prefiltered);
    }

    #endregion
}