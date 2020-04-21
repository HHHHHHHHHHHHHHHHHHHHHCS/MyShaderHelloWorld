using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

[CustomEditor(typeof(AdvancedImageEX), false)]
[CanEditMultipleObjects]
public class AdvancedImageEXEditor : ImageEditor
{
    SerializedProperty m_Visible;
    protected override void OnEnable()
    {
        base.OnEnable();

        m_Visible = serializedObject.FindProperty("m_visible");
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        EditorGUILayout.PropertyField(m_Visible);
        serializedObject.ApplyModifiedProperties();
    }
}
