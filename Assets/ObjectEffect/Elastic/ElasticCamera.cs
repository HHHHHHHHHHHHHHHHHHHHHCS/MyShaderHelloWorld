using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElasticCamera : MonoBehaviour
{
	private Camera mainCamera;

	private void Awake()
	{
		mainCamera = GetComponent<Camera>();
	}

	private void Update()
	{
		if (Input.GetMouseButtonDown(0))
		{
			if (Physics.Raycast(mainCamera.ScreenPointToRay(Input.mousePosition), out var hitInfo))
			{
				var elastic = hitInfo.collider.GetComponent<ElasticObject>();
				if(elastic)
				{
					elastic.OnElastic(hitInfo);
				}
			}
		}
	}
}