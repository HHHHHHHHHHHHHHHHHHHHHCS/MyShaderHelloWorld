using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class WayPoint
{
    public Vector3 pos;
}

[RequireComponent (typeof (MeshFilter))]
[RequireComponent (typeof (MeshRenderer))]
public class RiverSystem : MonoBehaviour
{
    public const string TAG = "River";
    
    //TODO:
}
