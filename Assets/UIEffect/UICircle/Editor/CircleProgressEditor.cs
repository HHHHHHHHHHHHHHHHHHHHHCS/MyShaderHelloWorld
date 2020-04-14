using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

[CustomEditor(typeof(UICircle), true)]
public class CircleProgressEditor : GraphicEditor
{
    // CircleImage _target;
    private SerializedProperty sprite;
    private SerializedProperty color;
    private SerializedProperty thickness;
    private SerializedProperty segements;

    private SerializedProperty sc_segements;
    //

    private SerializedProperty _surround;
    private SerializedProperty startAngle;
    private SerializedProperty minPercentage;
    private SerializedProperty maxPercentage;
    private SerializedProperty percentage;

    protected override void OnEnable()
    {
        base.OnEnable();
        // _target = (CircleImage)target;
        sprite = serializedObject.FindProperty("m_Sprite");
        color = serializedObject.FindProperty("m_Color");
        thickness = serializedObject.FindProperty("thickness");
        segements = serializedObject.FindProperty("segements");
        sc_segements = serializedObject.FindProperty("scSegments");
        _surround = serializedObject.FindProperty("surround");
        startAngle = serializedObject.FindProperty("startAngle");
        minPercentage = serializedObject.FindProperty("minPercentage");
        maxPercentage = serializedObject.FindProperty("maxPercentage");
        percentage = serializedObject.FindProperty("percentage");
    }

    [MenuItem("GameObject/UI/CircleProgress")]
    static void CricleImage()
    {
        GameObject parent = Selection.activeGameObject;
        RectTransform parentCanvasRenderer = (parent != null) ? parent.GetComponent<RectTransform>() : null;
        if (parentCanvasRenderer)
        {
            GameObject go = new GameObject("CircleProgress");
            go.transform.SetParent(parent.transform, false);
            go.AddComponent<RectTransform>();
            go.AddComponent<CanvasRenderer>();
            go.AddComponent<UICircle>();
            Selection.activeGameObject = go;
        }
        else
        {
            EditorUtility.DisplayDialog("CircleProgress",
                "You must make the CricleImage object as a child of a Canvas.", "Ok");
        }
    }

    // Update is called once per frame
    public override void OnInspectorGUI()
    {
        //EditorGUILayout.BeginHorizontal();

        //_target = (CircleImage)EditorGUILayout.ObjectField("Script", _target, typeof(CircleImage), true);

        //EditorGUILayout.EndHorizontal();

        serializedObject.Update();

        EditorGUILayout.PropertyField(sprite);
        EditorGUILayout.PropertyField(color);
        EditorGUILayout.PropertyField(thickness);
        EditorGUILayout.PropertyField(segements);
        EditorGUILayout.PropertyField(sc_segements);
        EditorGUILayout.PropertyField(_surround);
        EditorGUILayout.PropertyField(startAngle);
        EditorGUILayout.PropertyField(minPercentage);
        EditorGUILayout.PropertyField(maxPercentage);
        EditorGUILayout.PropertyField(percentage);
        EditorGUILayout.PropertyField(m_RaycastTarget);

        serializedObject.ApplyModifiedProperties();
    }
}