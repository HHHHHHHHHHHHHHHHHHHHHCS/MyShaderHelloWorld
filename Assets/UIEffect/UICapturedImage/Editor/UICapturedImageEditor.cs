using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

namespace UIEffect.Editors
{
    [CustomEditor(typeof(UICapturedImage)), CanEditMultipleObjects]
    public class UICapturedImageEditor : RawImageEditor
    {
        public enum QualityMode : int
        {
            Fast = (DesamplingRate.x2 << 0) + (DesamplingRate.x2 << 4) + (FilterMode.Bilinear << 8) + (2 << 10),
            Medium = (DesamplingRate.x1 << 0) + (DesamplingRate.x1 << 4) + (FilterMode.Bilinear << 8) + (3 << 10),
            Detail = (DesamplingRate.None << 0) + (DesamplingRate.x1 << 4) + (FilterMode.Bilinear << 8) + (5 << 10),
            Custom = -1
        }

        private const int bits4 = (1 << 4) - 1;
        private const int bits2 = (1 << 2) - 1;

        private static readonly GUIContent contentEffectColor = new GUIContent("颜色特效");

        private bool customAdvancedOption = false;

        private SerializedProperty material;
        private SerializedProperty texture;
        private SerializedProperty color;
        private SerializedProperty raycastTarget;
        private SerializedProperty effectMode;
        private SerializedProperty effectFactor;
        private SerializedProperty colorMode;
        private SerializedProperty desamplingRate;
        private SerializedProperty reductionRate;
        private SerializedProperty filterMode;
        private SerializedProperty iterations;
        private SerializedProperty keepSizeToRootCanvas;
        private SerializedProperty blurMode;
        private SerializedProperty captureOnEnable;
        private SerializedProperty immediateCapturing;

        private QualityMode Quality
        {
            get
            {
                if (customAdvancedOption)
                {
                    return QualityMode.Custom;
                }

                int qualityValue = (desamplingRate.intValue << 0)
                                   + (reductionRate.intValue << 4)
                                   + (filterMode.intValue << 8)
                                   + (iterations.intValue << 10);
                return Enum.IsDefined(typeof(QualityMode), qualityValue)
                    ? (QualityMode) qualityValue
                    : QualityMode.Custom;
            }
            set
            {
                if (value != QualityMode.Custom)
                {
                    int qualityValue = (int) value;
                    desamplingRate.intValue = (qualityValue >> 0) & bits4;
                    reductionRate.intValue = (qualityValue >> 4) & bits4;
                    filterMode.intValue = (qualityValue >> 8) & bits2;
                    iterations.intValue = (qualityValue >> 10) & bits4;
                }
            }
        }

        public override void OnInspectorGUI()
        {
            var graphic = target as UICapturedImage;

            //基础
            EditorGUILayout.PropertyField(texture);
            EditorGUILayout.PropertyField(color);
            EditorGUILayout.PropertyField(raycastTarget);

            GUILayout.Space(10);
            EditorGUILayout.LabelField("效果", EditorStyles.boldLabel);

            //材质球
            EditorGUI.BeginDisabledGroup(true);
            EditorGUILayout.PropertyField(material);
            EditorGUI.EndDisabledGroup();

            //特效模式
            EditorGUILayout.PropertyField(effectMode);
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(effectFactor);
                EditorGUI.indentLevel--;
            }

            //颜色模式
            EditorGUILayout.PropertyField(colorMode);
            EditorGUI.indentLevel++;
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = color.hasMultipleDifferentValues;
#if UNITY_2018_1_OR_NEWER
            color.colorValue =
                EditorGUILayout.ColorField(contentEffectColor, color.colorValue, true, false, false);
#else
				spColor.colorValue =
 EditorGUILayout.ColorField (contentEffectColor, spColor.colorValue, true, false, false, null);
#endif
            if (EditorGUI.EndChangeCheck())
            {
                color.serializedObject.ApplyModifiedProperties();
            }
            EditorGUILayout.PropertyField(effectFactor);
            EditorGUI.indentLevel--;

            //进阶设置
            GUILayout.Space(10);
            EditorGUILayout.LabelField("进阶设置", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(captureOnEnable);
            EditorGUILayout.PropertyField(keepSizeToRootCanvas);
            EditorGUILayout.PropertyField(immediateCapturing);

            //品质设定
            EditorGUI.BeginChangeCheck();
            QualityMode quality = Quality;
            quality = (QualityMode) EditorGUILayout.EnumPopup("效果品质", quality);
            if (EditorGUI.EndChangeCheck())
            {
                customAdvancedOption = (quality == QualityMode.Custom);
                Quality = quality;
            }


            //自定义品质
            if (customAdvancedOption)
            {
                if (blurMode.intValue != 0)
                {
                    EditorGUILayout.PropertyField(iterations);
                }
                //降低采样
                DrawDesamplingRate(reductionRate);

                EditorGUILayout.Space();
                EditorGUILayout.LabelField("最终图片设置", EditorStyles.boldLabel);

                //提升采样
                EditorGUILayout.PropertyField(filterMode);
                DrawDesamplingRate(desamplingRate);
            }

            serializedObject.ApplyModifiedProperties();

            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
            {
                GUILayout.Label("测试");

                if (GUILayout.Button("播放", "ButtonLeft"))
                {
                    graphic.Release();
                    EditorApplication.delayCall += graphic.Capture;
                }

                EditorGUI.BeginDisabledGroup(!graphic.CapturedTexture);
                if (GUILayout.Button("结束", "ButtonRight"))
                {
                    graphic.Release();
                }

                EditorGUI.EndDisabledGroup();
            }
        }


        protected override void OnEnable()
        {
            base.OnEnable();

            material = serializedObject.FindProperty("effectMaterial");
            texture = serializedObject.FindProperty("m_Texture");
            color = serializedObject.FindProperty("m_Color");
            raycastTarget = serializedObject.FindProperty("m_RaycastTarget");
            effectMode = serializedObject.FindProperty("effectMode");
            effectFactor = serializedObject.FindProperty("effectFactor");
            colorMode = serializedObject.FindProperty("colorMode");
            desamplingRate = serializedObject.FindProperty("desamplingRate");
            reductionRate = serializedObject.FindProperty("reductionRate");
            filterMode = serializedObject.FindProperty("filterMode");
            iterations = serializedObject.FindProperty("blurIterations");
            keepSizeToRootCanvas = serializedObject.FindProperty("fitToScreen");
            blurMode = serializedObject.FindProperty("blurMode");
            captureOnEnable = serializedObject.FindProperty("captureOnEnable");
            immediateCapturing = serializedObject.FindProperty("immediateCapturing");
        }

        /// <summary>
        /// 画采样率界面用
        /// </summary>
        private void DrawDesamplingRate(SerializedProperty sp)
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PropertyField(sp);
                (target as UICapturedImage).GetDesamplingSize((DesamplingRate) sp.intValue, out int w, out int h);
                GUILayout.Label($"{w}x{h}", EditorStyles.miniLabel);
            }
        }
    }
}