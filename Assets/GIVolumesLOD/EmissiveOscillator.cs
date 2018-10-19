using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EmissiveOscillator : MonoBehaviour
{
    private MeshRenderer emissiveRenderer;
    private Material emissiveMaterial;

    private void Start()
    {
        emissiveRenderer = GetComponent<MeshRenderer>();
        emissiveMaterial = emissiveRenderer.material;
    }

    private void Update()
    {
        Color c = Color.Lerp(
            Color.white, Color.black,
            Mathf.Sin(Time.time * Mathf.PI) * 0.5f + 0.5f
            );
        emissiveMaterial.SetColor("_Emission", c);
        //emissiveRenderer.UpdateGIMaterials();
        DynamicGI.SetEmissive(emissiveRenderer, c);
    }
}
