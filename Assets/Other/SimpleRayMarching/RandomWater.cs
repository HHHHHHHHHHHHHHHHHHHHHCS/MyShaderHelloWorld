using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomWater : MonoBehaviour
{
    private void Awake()
    {
        foreach (var item in GetComponentsInChildren<Rigidbody>())
        {
            item.velocity = (new Vector3(Random.value * 2 - 1, 0, Random.value * 2 - 1));
        }
    }
}