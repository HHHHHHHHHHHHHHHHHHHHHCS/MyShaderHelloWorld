using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect.Editors
{
    /// <summary>
    /// 梯度颜色编辑器
    /// </summary>
    [CustomEditor(typeof(UIGradient)), CanEditMultipleObjects]
    public class UIGradientEditor : UIBaseEffect
    {
        private SerializedProperty direction;
        private SerializedProperty color1;
        private SerializedProperty color2;
        private SerializedProperty color3;
        private SerializedProperty color4;
        private SerializedProperty rotation;
        private SerializedProperty offset1;
        private SerializedProperty offset2;
        private SerializedProperty effectArea;
        private SerializedProperty colorSpace;
        private SerializedProperty ignoreAspectRatio;

        private void OnEnable()
        {
            direction = FindProperty("direction");
            color1 = FindProperty("color1");
            color2 = FindProperty("color2");
            color3 = FindProperty("color3");
            color4 = FindProperty("color4");
            rotation = FindProperty("rotation");
            offset1 = FindProperty("offset1");
            offset2 = FindProperty("offset2");
            effectArea = FindProperty("effectArea");
            colorSpace = FindProperty("colorSpace");
            ignoreAspectRatio = FindProperty("ignoreAspectRatio");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            CreateLine(direction, "渐变方向");

            switch ((Direction) direction.intValue)
            {
                case Direction.Horizontal:
                {
                    CreateLine(color1, "左边");
                    CreateLine(color2, "右边");
                    break;
                }
                case Direction.Vertical:
                {
                    CreateLine(color1, "上边");
                    CreateLine(color2, "下边");
                    break;
                }
                case Direction.Angle:
                {
                    CreateLine(color1, "颜色1");
                    CreateLine(color2, "颜色2");
                    break;
                }
                case Direction.Diagonal:
                {
                    Rect r = EditorGUILayout.GetControlRect(false, 34); //得到一个34高的矩形

                    r = EditorGUI.PrefixLabel(r, Label("对角线颜色")); //显示矩形
                    float w = r.width / 2;

                    EditorGUI.PropertyField(new Rect(r.x, r.y + 18, w, 16), color1, GUIContent.none);
                    EditorGUI.PropertyField(new Rect(r.x + w, r.y + 18, w, 16), color2, GUIContent.none);
                    EditorGUI.PropertyField(new Rect(r.x, r.y, w, 16), color3, GUIContent.none);
                    EditorGUI.PropertyField(new Rect(r.x + w, r.y, w, 16), color4, GUIContent.none);

                    break;
                }
            }

            if ((int) Direction.Angle <= direction.intValue)
            {
                CreateLine(rotation, "旋转");
            }

            if ((int) Direction.Diagonal == direction.intValue)
            {
                CreateLine(offset1, "横偏移");
                CreateLine(offset2, "竖偏移");
            }
            else
            {
                CreateLine(offset1, "偏移");
            }


            EditorGUILayout.Space();
            EditorGUILayout.LabelField("进阶设置", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            {
                if ((target as UIGradient).TargetGraphic is Text)
                {
                    CreateLine(effectArea, "特效区域");
                }

                CreateLine(colorSpace, "颜色模式");
                CreateLine(ignoreAspectRatio, "忽略自适应");
            }
            EditorGUI.indentLevel--;

            serializedObject.ApplyModifiedProperties();
        }
    }
}