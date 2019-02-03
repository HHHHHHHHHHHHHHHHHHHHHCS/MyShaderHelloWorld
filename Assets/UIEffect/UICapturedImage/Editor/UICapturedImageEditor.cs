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

        private bool customAdvancedOption = false;

        private SerializedProperty texture;
        private SerializedProperty color;
        private SerializedProperty raycastTarget;
        private SerializedProperty desamplingRate;
        private SerializedProperty reductionRate;
        private SerializedProperty filterMode;
        private SerializedProperty iterations;
        private SerializedProperty keepSizeToRootCanvas;
        private SerializedProperty blurMode;
        private SerializedProperty captureOnEnable;
        private SerializedProperty immediateCapturing;

        private QualityMode qualityMode
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


        protected override void OnEnable()
        {
            base.OnEnable();

            texture = serializedObject.FindProperty("m_Texture");
            color = serializedObject.FindProperty("m_Color");
            raycastTarget = serializedObject.FindProperty("m_RaycastTarget");
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