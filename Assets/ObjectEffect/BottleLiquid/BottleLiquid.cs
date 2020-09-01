using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BottleLiquid : MonoBehaviour
{
	public float sinSpeed = 100;

	private Material liquidMat;

	private Vector3 lastPos;
	private Vector3 lastA;

	private float damping = 1;

	private void Start()
	{
		lastPos = transform.position;
		lastA = Vector3.zero;
		liquidMat = GetComponent<MeshRenderer>().sharedMaterial;
	}

	private void Update()
	{
		Vector3 currentDir = transform.position - lastPos;
		if (currentDir.magnitude > (lastA.magnitude * damping))
		{
			lastA = currentDir;
			damping = 1;
		}

		damping *= 0.99f;

		Vector3 sinDir = Mathf.Sin(Time.time * sinSpeed) * lastA * damping;
		liquidMat.SetVector("_ForceDir",sinDir);
		lastPos = transform.position;
	}
}
