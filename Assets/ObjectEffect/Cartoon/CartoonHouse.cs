using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CartoonHouse : MonoBehaviour
{
    public Material[] mats;

    public bool showSnow;

    private void OnEnable()
    {
        if (mats == null)
        {
            return;
        }

        if (showSnow)
        {
            foreach (var mat in mats)
            {
                mat.EnableKeyword("SNOW_ON");
            }
        }
        else
        {
            foreach (var mat in mats)
            {
                mat.DisableKeyword("SNOW_ON");
            }
        }
    }
}