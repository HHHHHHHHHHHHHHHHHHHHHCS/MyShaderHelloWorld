using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MyLightingShaderGUI_TriplanarMapping : MyLightingShaderGUI_TriplanarMapping_Base
{
    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
    {
        base.OnGUI(editor, properties);
        editor.ShaderProperty(FindProperty("_MapScale"), MakeLabel("Map Scale"));
        DoMaps();
        DoBlending();
        DoOtherSettings();
    }

    void DoMaps()
    {
        GUILayout.Label("Maps", EditorStyles.boldLabel);
        editor.TexturePropertySingleLine(
            MakeLabel("Albedo"), FindProperty("_MainTex"));
        editor.TexturePropertySingleLine(
            MakeLabel("MOHS", "Metallic (R) Occlusion (G) Height(B) Smoothness(A)")
            , FindProperty("_MOHSMap"));
        editor.TexturePropertySingleLine(
            MakeLabel("Normals"),FindProperty("_MormalMap"));
    }

    void DoBlending()
    {
        GUILayout.Label("Blending", EditorStyles.boldLabel);

        editor.ShaderProperty(FindProperty("_BlendOffset"), MakeLabel("Offest"));
        editor.ShaderProperty(FindProperty("_BlendExponent"), MakeLabel("Expoent"));
        editor.ShaderProperty(FindProperty("_BlendHeightStrength"), MakeLabel("Height Strength"));
    }

    void DoOtherSettings()
    {
        GUILayout.Label("Other Settings", EditorStyles.boldLabel);

        editor.RenderQueueField();
        editor.EnableInstancingField();
    }
}
