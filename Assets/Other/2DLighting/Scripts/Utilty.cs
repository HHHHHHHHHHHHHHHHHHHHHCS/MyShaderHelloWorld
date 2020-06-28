using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Lighting2D
{
	public static class Utilty 
	{
		public static void ForEach<T>(this IEnumerable<T> ts, Action<T> callback)
		{
			foreach (var item in ts)
			{
				callback(item);
			}
		}

		public static IEnumerable<GameObject> GetChildren(this GameObject gameObject)
		{
			for (var i = 0; i < gameObject.transform.childCount; ++i)
			{
				yield return gameObject.transform.GetChild(i).gameObject;
			}
		}
		
	}
}