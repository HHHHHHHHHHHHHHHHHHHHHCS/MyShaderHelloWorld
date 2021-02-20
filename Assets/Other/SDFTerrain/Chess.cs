using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class Chess : MonoBehaviour
{
	private void OnEnable()
	{
		if (Chessboard.Instance)
		{
			Chessboard.Instance.AddMember(this);
		}
	}

	private void OnDisable()
	{
		if (Chessboard.Instance)
		{
			Chessboard.Instance.RemoveMember(this);
		}
	}

	[Header("对地表的影响力"), Range(0, 10)] public float force = 1;
	private MeshFilter _mf;

	public MeshFilter mf
	{
		get
		{
			if (_mf == null)
			{
				_mf = GetComponent<MeshFilter>();
			}

			return _mf;
		}
	}

}
