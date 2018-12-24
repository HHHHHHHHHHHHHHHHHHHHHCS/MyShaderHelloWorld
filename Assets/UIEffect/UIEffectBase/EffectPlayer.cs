using UnityEngine;
using System;
using System.Collections.Generic;

namespace UIEffect
{
    /// <summary>
    /// 特效的播放器
    /// </summary>
    [Serializable]
    public class EffectPlayer
    {
        /// <summary>
        /// 更新的事件
        /// </summary>
        private static List<Action> updateActions;

        /// <summary>
        /// 是否在播放
        /// </summary>
        [Tooltip("Playing")] public bool play = false;

        /// <summary>
        /// 是否循环
        /// </summary>
        [Tooltip("Loop")] public bool loop = false;

        /// <summary>
        /// 播放的时间
        /// </summary>
        [Range(0.01f, 10f), Tooltip("Duration")]
        public float duration = 1;

        /// <summary>
        /// 循环播放的延迟
        /// </summary>
        [Range(0, 10f), Tooltip("Delay before looping")]
        public float loopDelay = 0;

        /// <summary>
        /// 动画的时间方式
        /// </summary>
        [Tooltip("Update Mode")] public AnimatorUpdateMode updateMode = AnimatorUpdateMode.Normal;

        /// <summary>
        /// 特效已经播放的时间
        /// </summary>
        private float timer = 0;

        /// <summary>
        /// 播放完的回调
        /// </summary>
        private Action<float> callback;

        /// <summary>
        /// 注册事件
        /// </summary>
        public void OnEnable(Action<float> _callback = null)
        {
            if (updateActions == null)
            {
                updateActions = new List<Action>();
                Canvas.willRenderCanvases += () =>
                {
                    foreach (var act in updateActions)
                    {
                        act();
                    }
                };
            }

            updateActions.Add(OnWillRenderCanvases);

            timer = 0;
            callback = _callback;
        }

        /// <summary>
        /// 注销事件
        /// </summary>
        public void OnDisable()
        {
            callback = null;
            updateActions.Remove(OnWillRenderCanvases);
        }

        /// <summary>
        /// 开始播放
        /// </summary>
        public void Play(Action<float> _callback = null)
        {
            timer = 0;
            play = true;
            if (callback != null)
            {
                callback = _callback;
            }
        }

        /// <summary>
        /// 暂停播放
        /// </summary>
        public void Stop()
        {
            play = false;
        }

        /// <summary>
        /// 动画进行播放时,根据动画的播放进度,每次进行回调
        /// </summary>
        private void OnWillRenderCanvases()
        {
            if (!play || !Application.isPlaying || callback == null)
            {
                return;
            }

            timer += updateMode == AnimatorUpdateMode.UnscaledTime
                ? Time.unscaledDeltaTime
                : Time.deltaTime;
            var current = timer / duration;

            if (duration <= timer)
            {
                play = loop;
                timer = loop ? -loopDelay : 0;
            }

            callback(current);
        }
    }
}