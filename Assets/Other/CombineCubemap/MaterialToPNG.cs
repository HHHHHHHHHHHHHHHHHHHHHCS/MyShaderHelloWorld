using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class MaterialToPNG : MonoBehaviour
{
    //如果是对付skybox 则宽:长=1:2
    public int width = 4096, height = 2048;
    public string path = "Assets/Other/CombineCubemap/skybox.tga";


    private void Start()
    {
        var mat = GetComponent<MeshRenderer>().material;
        RenderTexture rt = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32);
        Graphics.Blit(null, rt, mat);
        Texture2D t2d = new Texture2D(width, height, TextureFormat.RGB24, false, false);
        RenderTexture.active = rt;
        t2d.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        t2d.Apply();
        using (var sw = File.Create(path))
        {
            var data = t2d.EncodeToTGA();
            sw.Write(data, 0, data.Length);
        }

        AssetDatabase.Refresh();
    }
}