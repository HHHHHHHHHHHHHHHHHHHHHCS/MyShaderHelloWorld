using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class MaterialToPNG : MonoBehaviour
{
    public int size = 4096;
    public string path = "Assets/Other/CombineCubemap/skybox.tga";


    private void Start()
    {
        var mat = GetComponent<MeshRenderer>().material;
        RenderTexture rt = new RenderTexture(size, size, 0, RenderTextureFormat.ARGB32);
        Graphics.Blit(null, rt, mat);
        Texture2D t2d = new Texture2D(size, size, TextureFormat.RGB24, false, false);
        RenderTexture.active = rt;
        t2d.ReadPixels(new Rect(0, 0, size, size), 0, 0);
        t2d.Apply();
        using (var sw = File.Create(path))
        {
            var data = t2d.EncodeToTGA();
            sw.Write(data, 0, data.Length);
        }
        AssetDatabase.Refresh();
    }
}