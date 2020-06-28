using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Lighting2D.Editor
{
	[CustomEditor(typeof(MonoBehaviour), true)]
	public class ButtonEditorHelper : UnityEditor.Editor
	{
		public override void OnInspectorGUI()
		{
			base.OnInspectorGUI();
			target.GetType().GetMethods()
				.Where(method =>
					method.GetCustomAttributes(typeof(EditorButtonAttribute), true).FirstOrDefault() != null)
				.ForEach(method =>
				{
					var attr =
						method.GetCustomAttributes(typeof(EditorButtonAttribute), true).FirstOrDefault() as
							EditorButtonAttribute;
					var label = attr.label;
					if (label == "")
						label = method.Name;
					if (GUILayout.Button(label))
						method.Invoke(target, new object[] { });
				});
		}
	}
}