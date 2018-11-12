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

    }

    void DoBlending()
    {

    }

    void DoOtherSettings()
    {

    }
}
