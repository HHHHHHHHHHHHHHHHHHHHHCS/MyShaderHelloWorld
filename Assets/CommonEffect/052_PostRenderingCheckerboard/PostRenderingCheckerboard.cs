using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostRenderingCheckerboard : MonoBehaviour 
{
	public Material mat;

	public void OnRenderImage (RenderTexture source, RenderTexture destination) 
	{
		if(mat)
		{
			Graphics.Blit (source, destination, mat);
		}
	}
}