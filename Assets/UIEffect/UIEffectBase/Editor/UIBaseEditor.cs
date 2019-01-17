using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace UIEffect.Editors
{
    public class UIBaseEffect : Editor
    {
        protected static GUIContent content = new GUIContent();

        protected void FindProperty(out SerializedProperty sp, string name, SerializedProperty so = null)
        {
            sp = so == null
                ? serializedObject.FindProperty(name)
                : so.FindPropertyRelative(name);
        }

        protected SerializedProperty FindProperty(string name, SerializedProperty so = null)
        {
            return so == null
                ? serializedObject.FindProperty(name)
                : so.FindPropertyRelative(name);
        }



        protected void CreateLine(SerializedProperty sp, string text = null)
        {
            if (string.IsNullOrEmpty(text))
            {
                EditorGUILayout.PropertyField(sp);
            }
            else
            {
                EditorGUILayout.PropertyField(sp, Label(text));
            }
        }

        protected GUIContent Label(string text)
        {
            content.text = text;
            return content;
        }
    }
}