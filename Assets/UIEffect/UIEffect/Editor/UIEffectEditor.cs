using System.Collections;
using System.Collections.Generic;
using UIEffect.Editors;
using UnityEngine;
using UnityEditor;
using System.Linq;

namespace UIEffect.Editors
{
    [CustomEditor(typeof(UIEffect)), CanEditMultipleObjects]
    public class UIEffectEditor : UIBaseEffect
    {
        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            //开启第二个通道
            var graphic = (target as UIEffectBase)?.TargetGraphic;
            if (graphic)
            {
                var canvas = graphic.canvas;
                if (canvas &&
                    (canvas.additionalShaderChannels 
                     & AdditionalCanvasShaderChannels.TexCoord1)
                        == 0)
                {
                    canvas.additionalShaderChannels |= AdditionalCanvasShaderChannels.TexCoord1;
                }
            }

            var material = FindProperty("effectMaterial");
            EditorGUI.BeginDisabledGroup(true);
            CreateLine(material, "材质球");
            EditorGUI.EndDisabledGroup();

            var effectMode = FindProperty("effectMode");
            CreateLine(effectMode, "特效模式");

            if (effectMode.intValue != (int) EffectMode.None)
            {
                EditorGUI.indentLevel++;
                CreateLine(FindProperty("effectFactor"), "影响程度");
                EditorGUI.indentLevel--;
            }

            var colorMode = FindProperty("colorMode");
            CreateLine(colorMode, "颜色模式");

            EditorGUI.indentLevel++;
            var color = FindProperty("color");
            if (color == null && serializedObject.targetObject is UIEffect)
            {
                //m_Color 是 UI 源码内嵌的color
                color = new SerializedObject(serializedObject.targetObjects
                        .Select(x => (x as UIEffect)?.TargetGraphic).ToArray())
                    .FindProperty("m_Color");
            }

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = color.hasMultipleDifferentValues;
            color.colorValue = EditorGUILayout.ColorField(Label("特效颜色"), color.colorValue, true, false, false);

            if (EditorGUI.EndChangeCheck())
            {
                color.serializedObject.ApplyModifiedProperties();
            }

            CreateLine(FindProperty("colorFactor"), "颜色影响程度");

            EditorGUI.indentLevel--;

            var blurMode = FindProperty("blurMode");

            CreateLine(blurMode, "模糊模式");

            if (blurMode.intValue != (int) BlurMode.None)
            {
                EditorGUI.indentLevel++;
                CreateLine(FindProperty("blurFactor"), "模糊影响程度");

                var advancedBlur = FindProperty("advancedBlur");
                if (advancedBlur != null)
                {
                    CreateLine(advancedBlur, "高级模糊");
                }

                EditorGUI.indentLevel--;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}