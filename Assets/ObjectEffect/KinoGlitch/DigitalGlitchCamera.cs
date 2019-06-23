using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class DigitalGlitchCamera : MonoBehaviour
{
    public Shader shader;

    [Range(0, 1)] public float intensity = 0;

    private Material mat;
    private Texture2D noiseTexture;
    private RenderTexture frameRT1;
    private RenderTexture frameRT2;

    public static Color RandomColor() => new Color(Random.value, Random.value, Random.value, Random.value);

    private void SetUpResources()
    {
        if (mat != null)
        {
            return;
        }

        mat = new Material(shader);
        mat.hideFlags = HideFlags.DontSave;

        noiseTexture = new Texture2D(64, 32, TextureFormat.ARGB32, false);
        noiseTexture.hideFlags = HideFlags.DontSave;
        noiseTexture.wrapMode = TextureWrapMode.Clamp;
        noiseTexture.filterMode = FilterMode.Point;

        frameRT1 = new RenderTexture(Screen.width, Screen.height, 0);
        frameRT2 = new RenderTexture(Screen.width, Screen.height, 0);
        frameRT1.hideFlags = HideFlags.DontSave;
        frameRT2.hideFlags = HideFlags.DontSave;
    }

    void UpdateNoiseTexture()
    {
        var color = RandomColor();

        for (var y = 0; y < noiseTexture.height; y++)
        {
            for (var x = 0; x < noiseTexture.width; x++)
            {
                if (Random.value > 0.89f) color = RandomColor();
                noiseTexture.SetPixel(x, y, color);
            }
        }

        noiseTexture.Apply();
    }


    void Update()
    {
        if (Random.value > Mathf.Lerp(0.9f, 0.5f, intensity))
        {
            SetUpResources();
            UpdateNoiseTexture();
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetUpResources();

        // Update trash frames on a constant interval.
        var fcount = Time.frameCount;
        if (fcount % 13 == 0) Graphics.Blit(source, frameRT1);
        if (fcount % 73 == 0) Graphics.Blit(source, frameRT2);

        mat.SetFloat("_Intensity", intensity);
        mat.SetTexture("_NoiseTex", noiseTexture);
        var trashFrame = Random.value > 0.5f ? frameRT1 : frameRT2;
        mat.SetTexture("_TrashTex", trashFrame);

        Graphics.Blit(source, destination, mat);
    }
}