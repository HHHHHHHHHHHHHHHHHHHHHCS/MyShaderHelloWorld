using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class MyLightingShaderGUI : ShaderGUI
{
    private MaterialEditor editor;
    private MaterialProperty[] properties;

    private MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, properties);
    }

    private static GUIContent staticLabel = new GUIContent();

    private static GUIContent MakeLabel(string text, string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    private static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
    {
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.editor = materialEditor;
        this.properties = properties;
        DoMain();
        DoSecondary();
    }


    private void DoMain()
    {
        GUILayout.Label("Main mape");
        MaterialProperty mainTex = FindProperty("_MainTex");
        editor.TexturePropertySingleLine(MakeLabel(mainTex.displayName, "Albedo (RGB)")
            , mainTex, FindProperty("_Tint"));
        DoMetallic();
        DoSmoothness();
        DoNormals();
        editor.TextureScaleOffsetProperty(mainTex);
    }

    private void DoMetallic()
    {
        MaterialProperty map = FindProperty("_MetallicMap");
        editor.TexturePropertySingleLine(
            MakeLabel(map, "Metallic (R)"), map,
            FindProperty("_Metallic")
        );
    }

    private void DoSmoothness()
    {
        EditorGUI.indentLevel += 2;
        MaterialProperty slider = FindProperty("_Smoothness");
        editor.ShaderProperty(slider, MakeLabel(slider));
        EditorGUI.indentLevel -= 2;
    }

    private void DoNormals()
    {
        MaterialProperty map = FindProperty("_NormalMap");
        editor.TexturePropertySingleLine(MakeLabel(map), map
            , map.textureValue ? FindProperty("_BumpScale") : null);
    }

    private void DoSecondary()
    {
        GUILayout.Label("secondary maps", EditorStyles.boldLabel);
        MaterialProperty detailTex = FindProperty("_DetailTex");
        editor.TexturePropertySingleLine(MakeLabel(detailTex, "Albedo (RGB) multiplied by 2")
            , detailTex);
        DoSecondaryNormals();
        editor.TextureScaleOffsetProperty(detailTex);
    }

    private void DoSecondaryNormals()
    {
        MaterialProperty map = FindProperty("_DetailNormalMap");
        editor.TexturePropertySingleLine(MakeLabel(map), map
            , map.textureValue ? FindProperty("_DetailBumpScale") : null);
    }
}
