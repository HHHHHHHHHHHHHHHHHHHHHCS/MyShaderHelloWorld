using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElasticObject : MonoBehaviour
{
	private int posID, norID, timeID;

	private MeshRenderer meshRenderer;

	private void Awake()
	{
		posID = Shader.PropertyToID("_Position");
		norID = Shader.PropertyToID("_Normal");
		timeID = Shader.PropertyToID("_PointTime");

		meshRenderer = GetComponent<MeshRenderer>();
	}

	public void OnElastic(RaycastHit hit)
	{
		//反弹的坐标
		Vector4 v = transform.InverseTransformPoint(hit.point);
		//影响半径
		v.w = 0.6f;
		meshRenderer.sharedMaterial.SetVector(posID, v);
		//点击点的法线方向
		v = transform.InverseTransformDirection(hit.normal.normalized);
		//反弹力度
		v.w = 0.2f;
		meshRenderer.sharedMaterial.SetVector(norID, v);
		//重置时间
		meshRenderer.sharedMaterial.SetFloat(timeID, Time.time);
	}
}