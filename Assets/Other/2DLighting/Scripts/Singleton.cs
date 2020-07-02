using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Lighting2D
{
	public class Singleton<T> : MonoBehaviour where T : Singleton<T>
	{
		private static List<T> instances = new List<T>();

		public static T Instance
		{
			get
			{
				foreach (var item in instances)
				{
					if (item && item.gameObject.scene != null)
					{
						return item;
					}
				}

				return null;
			}
		}

		public Singleton() : base()
		{
			instances.Add(this as T);
		}
	}
}