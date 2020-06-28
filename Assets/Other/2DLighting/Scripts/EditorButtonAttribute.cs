using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Lighting2D.Editor
{
	[System.AttributeUsage(AttributeTargets.Method,Inherited = true,AllowMultiple = false)]
	public class EditorButtonAttribute : Attribute
	{
		public string label { get; private set; }

		public EditorButtonAttribute(string _label = "")
		{
			label = _label;
		}
	}
}