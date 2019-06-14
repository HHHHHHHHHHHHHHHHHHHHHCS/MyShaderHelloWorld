using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class KinoGlitchCamera : MonoBehaviour
{
    public Shader shader;

    [Range(0, 1)] public float scanLineJitter = 0;

    [Range(0, 1)] public float verticalJump = 0;

    [Range(0, 1)] public float horizontalShake;

    [Range(0, 1)] public float colorDrift = 0;

    private Material mat;
    private float verticalJumpTime;

    private void OnEnable()
    {
        if (!shader)
        {
            return;
        }

        mat = new Material(shader) {hideFlags = HideFlags.HideAndDontSave};
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!mat)
        {
            return;
        }

        verticalJump += Time.deltaTime * verticalJump * 11.3f;

        var sl_thresh = Mathf.Clamp01(1.0f - scanLineJitter * 1.2f);
        var sl_disp = 0.002f + Mathf.Pow(scanLineJitter, 3) * 0.05f;
        mat.SetVector("_ScanLineJitter", new Vector2(sl_disp, sl_thresh));

        var vj = new Vector2(verticalJump, verticalJump);
        mat.SetVector("_VerticalJump", vj);


        mat.SetFloat("_HorizontalShake", horizontalShake * 0.2f);

        var cd = new Vector2(colorDrift * 0.04f, Time.time * 606.11f);
        mat.SetVector("_ColorDrift", cd);

        Graphics.Blit(src, dest, mat);
    }
}