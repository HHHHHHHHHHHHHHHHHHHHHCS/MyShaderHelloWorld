using UnityEditor;
using UnityEngine;

namespace UIEffect.Editors
{
    [CustomEditor(typeof(UITransition)), CanEditMultipleObjects]
    public class UITransitionEditor : UIBaseEffect
    {
        private SerializedProperty material;
        private SerializedProperty transitionMode;
        private SerializedProperty effectFactor;
        private SerializedProperty effectArea;
        private SerializedProperty keepAspectRatio;
        private SerializedProperty dissolveWidth;
        private SerializedProperty dissolveSoftness;
        private SerializedProperty dissolveColor;
        private SerializedProperty transitionTexture;
        private SerializedProperty duration;
        private SerializedProperty updateMode;
        private SerializedProperty passRayOnHidden;

        private void OnEnable()
        {
            FindProperty(out material, "effectMaterial");
            FindProperty(out transitionMode, "transitionMode");
            FindProperty(out effectFactor, "effectFactor");
            FindProperty(out effectArea, "effectArea");
            FindProperty(out keepAspectRatio, "keepAspectRatio");
            FindProperty(out dissolveWidth, "dissolveWidth");
            FindProperty(out dissolveSoftness, "dissolveSoftness");
            FindProperty(out dissolveColor, "dissolveColor");
            FindProperty(out transitionTexture, "transitionTexture");
            FindProperty(out SerializedProperty player, "player");
            FindProperty(out duration, "duration", player);
            FindProperty(out updateMode, "updateMode", player);
            FindProperty(out passRayOnHidden, "passRayOnHidden");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUI.BeginDisabledGroup(true);
            CreateLine(material, "材质球");
            EditorGUI.EndDisabledGroup();

            CreateLine(transitionMode);

            EditorGUI.indentLevel++;
            CreateLine(effectFactor, "特效播放进度");
            if (transitionMode.intValue == (int) TransitionMode.Dissolve)
            {
                CreateLine(dissolveWidth, "流光宽度");
                CreateLine(dissolveSoftness, "流光软边");
                CreateLine(dissolveColor, "流光颜色");
            }

            EditorGUI.indentLevel--;

            GUILayout.Space(10);
            EditorGUILayout.LabelField("高级设置", EditorStyles.boldLabel);

            CreateLine(effectArea,"特效区域");
            CreateLine(transitionTexture, "噪音图");
            CreateLine(keepAspectRatio, "用噪音图的纵横比");
            CreateLine(passRayOnHidden, "播放时Mask");

            GUILayout.Space(10);
            EditorGUILayout.LabelField("播放器", EditorStyles.boldLabel);
            CreateLine(duration, "播放时间");
            CreateLine(updateMode, "时间模式");

            using (new EditorGUI.DisabledGroupScope(!Application.isPlaying))
            {
                using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
                {
                    GUILayout.Label("Debug");

                    if (GUILayout.Button("播放", "ButtonLeft"))
                    {
                        (target as UITransition)?.Show();
                    }

                    if (GUILayout.Button("暂停", "ButtonRight"))
                    {
                        (target as UITransition)?.Stop();
                    }
                }
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}