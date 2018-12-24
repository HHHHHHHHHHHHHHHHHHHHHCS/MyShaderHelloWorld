using UnityEditor;
using UnityEngine;

namespace UIEffect.Editors
{
    /// <summary>
    /// 流光的Editor 面板
    /// </summary>
    [CustomEditor(typeof(UIShiny)), CanEditMultipleObjects]
    public class UIShinyEditor : Editor
    {
        private static GUIContent content = new GUIContent();

        private SerializedProperty mat; //流光的材质
        private SerializedProperty color; //流光的颜色
        private SerializedProperty effectFactor; //当前特效的播放进度
        private SerializedProperty width; //当前流光的宽度
        private SerializedProperty rotation; //流光的旋转
        private SerializedProperty softness; //流光的软边
        private SerializedProperty brightness; //流光的亮度
        private SerializedProperty gloss; //流光的曝光度
        private SerializedProperty effectArea; //流光的光区域
        private SerializedProperty play; //流光是否播放
        private SerializedProperty loop; //流光是否循环
        private SerializedProperty loopDelay; //流光循环的延迟
        private SerializedProperty duration; //流光的播放时间
        private SerializedProperty updateMode; //流光的时间更新模式

        private void OnEnable()
        {
            mat = FindProperty("effectMaterial");
            color = FindProperty("shinyColor");
            effectFactor = FindProperty("effectFactor");
            width = FindProperty("width");
            rotation = FindProperty("rotation");
            softness = FindProperty("softness");
            brightness = FindProperty("brightness");
            gloss = FindProperty("gloss");
            effectArea = FindProperty("effectArea");
            var player = FindProperty("player");
            play = FindProperty("play", player);
            loop = FindProperty("loop", player);
            loopDelay = FindProperty("loopDelay", player);
            duration = FindProperty("duration", player);
            updateMode = FindProperty("updateMode", player);
        }


        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUI.BeginDisabledGroup(true);
            EditorGUILayout.PropertyField(mat, Label("材质球"));
            EditorGUI.EndDisabledGroup();

            CreateLine(effectFactor, "进度");
            CreateLine(color, "颜色");
            CreateLine(width, "宽度");
            CreateLine(rotation, "旋转");
            CreateLine(softness, "软边");
            CreateLine(brightness, "亮度");
            CreateLine(gloss, "曝光度");
            CreateLine(effectArea, "区域");

            GUILayout.Space(10);
            EditorGUILayout.LabelField("特效播放器", EditorStyles.boldLabel);
            CreateLine(play, "是否在播放");
            CreateLine(duration, "播放时长");
            CreateLine(loop, "是否循环");
            CreateLine(loopDelay, "循环延迟");
            CreateLine(updateMode, "时间模式");

            using (new EditorGUI.DisabledGroupScope(!Application.isPlaying))
            {
                using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
                {
                    GUILayout.Label("测试");

                    if (GUILayout.Button("播放", "ButtonLeft"))
                    {
                        (target as UIShiny)?.Play();
                    }

                    if (GUILayout.Button("暂停", "ButtonRight"))
                    {
                        (target as UIShiny)?.Stop();
                    }
                }
            }

            serializedObject.ApplyModifiedProperties();
        }

        private SerializedProperty FindProperty(string name, SerializedProperty so = null)
        {
            return so == null
                ? serializedObject.FindProperty(name)
                : so.FindPropertyRelative(name);
        }

        private void CreateLine(SerializedProperty sp, string text = null)
        {
            if (string.IsNullOrEmpty(text))
            {
                EditorGUILayout.PropertyField(sp);
            }
            else
            {
                EditorGUILayout.PropertyField(sp, Label(text));
            }
        }

        private GUIContent Label(string text)
        {
            content.text = text;
            return content;
        }
    }
}