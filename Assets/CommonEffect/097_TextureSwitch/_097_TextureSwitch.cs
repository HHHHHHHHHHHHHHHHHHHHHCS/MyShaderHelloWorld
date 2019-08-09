using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class _097_TextureSwitch : MonoBehaviour
{
    public int radius = 10;

    private Material mat;
    private GameObject player;

    private void Start()
    {
        mat = GetComponent<Renderer>().material;
        player = GameObject.Find("Player");
    }

    private void Update()
    {
        mat.SetVector("_PlayerPos", player.transform.position);
        mat.SetFloat("_Dist", radius);
    }
}