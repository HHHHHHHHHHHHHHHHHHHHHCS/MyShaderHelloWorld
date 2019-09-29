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

        [SerializeField,Range(0,1)]
        [Tooltip("使低于/高于阈值之间的过渡逐渐进行")]
        public float softKnee;

        [SerializeField, Range(1, 7)]
        [Tooltip("以与屏幕分辨率无关的方式更改遮罩效果的范围")]
        public float radius;

        [SerializeField]
        [Tooltip("混合图像的因子")]
        public float intensity;

        [SerializeField]
        [Tooltip("高清,控制过滤器质量和缓冲区分辨率")]
        public bool highQuality;

        [SerializeField]
        [Tooltip("抗锯齿,额外的滤波器可以减少锯齿")]
        public bool antiFlicker;

        [Tooltip("增加屏幕的脏感觉")]
        public Texture dirtTexture;

        [Min(0f), Tooltip("脏感觉强度")]
        public float dirtIntensity;

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

    [SerializeField]
    public Settings settings = Settings.defaultSettings;

    #endregion

    [SerializeField,HideInInspector]
    private Shader shader;

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
            //if (material == null)
                //m_Material = ImageEffectHelper.CheckShaderAndCreateMaterial(shader);

            return material;
        }
    }

}