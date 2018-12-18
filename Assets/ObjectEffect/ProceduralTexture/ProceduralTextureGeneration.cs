using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    #region Material properties

    [SerializeField]
    private int m_textureWidth = 512;

    [SerializeField]
    private Color m_backgroundColor = Color.white;

    [SerializeField]
    private Color m_circleColor = Color.yellow;

    [SerializeField]
    private float m_blurFactor = 2.0f;

    public int TextureWidth
    {
        get;
        set;
    }

    public Color BackgroundColor
    {
        get;
        set;
    }

    public Color CircleColor
    {
        get;
        set;
    }

    public float BlurFactor
    {
        get;

        set;
    }
    #endregion


    private Texture2D m_generatedTexture = null;

    private void Start()
    {
        if(material==null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer==null)
            {
                Debug.Log("Can't find renderer");
                return;
            }
            material = renderer.sharedMaterial;
        }
    }

    private void Update()
    {
        bool isChanged = false;
        if(m_textureWidth != TextureWidth)
        {
            TextureWidth = m_textureWidth;
            isChanged = true;
        }
        if(m_backgroundColor!=BackgroundColor)
        {
            BackgroundColor = m_backgroundColor;
            isChanged = true;
        }
        if (m_circleColor != CircleColor)
        {
            CircleColor = m_circleColor;
            isChanged = true;
        }
        if (m_blurFactor != BlurFactor)
        {
            BlurFactor = m_blurFactor;
            isChanged = true;
        }
        
        if(isChanged)
        {
            _UpdateMaterial();
        }
    }

    private void _UpdateMaterial()
    {
        if(material!=null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }


    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(m_textureWidth, m_textureWidth);

        float circleInterval = m_textureWidth / 4;
        float radius = m_textureWidth / 10f;
        float edgeBlur = 1.0f / m_blurFactor;

        for(int w=0;w<m_textureWidth;w++)
        {
            for (int h = 0; h < m_textureWidth; h++)
            {
                Color pixel = m_backgroundColor;
                for(int i=0;i<3;i++)
                {
                    for(int j=0;j<3;j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        Color color = _MixColor(m_circleColor
                            , new Color(pixel.r, pixel.g, pixel.b, 0.0f)
                            , Mathf.SmoothStep(0, 1, dist * edgeBlur));

                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();

        return proceduralTexture;
    }
}
