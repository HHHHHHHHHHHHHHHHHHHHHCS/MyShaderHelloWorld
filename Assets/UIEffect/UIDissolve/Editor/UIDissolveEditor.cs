using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace UIEffect.Editors
{
    [CustomEditor(typeof(UIDissolve)),CanEditMultipleObjects]
    public class UIDissolveEditor : UIBaseEffect
    {
        private SerializedProperty mat;//材质
        private SerializedProperty effectFactor;//播放进度
        private SerializedProperty width;//宽度
        private SerializedProperty dissolveColor;//溶解颜色
        private SerializedProperty softness;//软边
        private SerializedProperty colorMode;//颜色模式
        private SerializedProperty noiseTexture;//噪音图
        private SerializedProperty effectArea;//特效区域
        private SerializedProperty keepAspectRatio;//保持纵横比
        private SerializedProperty play;//播放
        private SerializedProperty loop;//循环
        private SerializedProperty loopDelay;//循环延迟
        private SerializedProperty duration;//周期
        private SerializedProperty updateMode;//更新模式

        private void OnEnable()
        {
            mat = FindProperty("effectMaterial");
            effectFactor = FindProperty("effectFactor");
            effectArea = FindProperty("effectArea");
            keepAspectRatio = FindProperty("keepAspectRatio");
            width = FindProperty("width");
            dissolveColor = FindProperty("dissolveColor");
            softness = FindProperty("softness");
            colorMode = FindProperty("colorMode");
            noiseTexture = FindProperty("noiseTexture");
            keepAspectRatio = FindProperty("keepAspectRatio");
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
            CreateLine(mat, "材质球");
            EditorGUI.EndDisabledGroup();

            CreateLine(effectFactor, "进度");
            CreateLine(width, "宽度");
            CreateLine(softness, "软边");
            CreateLine(dissolveColor, "颜色");
            CreateLine(colorMode, "颜色模式");
            CreateLine(noiseTexture, "噪音图");

            GUILayout.Space(10);
            CreateLine(effectArea, "特效区域");
            CreateLine(keepAspectRatio, "纵横比例");

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
    }
}