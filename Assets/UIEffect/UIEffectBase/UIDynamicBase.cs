using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// UI动态特效的基础类
    /// </summary>
    public abstract class UIDynamicBase : UIEffectBase
    {
        /// <summary>
        /// 流光的位置百分比
        /// </summary>
        [SerializeField, Range(0, 1), Tooltip("播放时间的比例")]
        protected float effectFactor;


        /// <summary>
        /// 流光的播放器
        /// </summary>
        [SerializeField] protected EffectPlayer player;

        /// <summary>
        /// 特效的播放进度 0~1
        /// 如果set 的值过于近似也不会有效果
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set
            {
                value = Mathf.Clamp(value, 0, 1);
                if (!Mathf.Approximately(effectFactor, value))
                {
                    effectFactor = value;
                    SetDirty();
                }
            }
        }

        /// <summary>
        /// 特效的播放器
        /// </summary>
        protected EffectPlayer Player => player ?? (player = new EffectPlayer());

        /// <summary>
        /// 是否播放特效
        /// </summary>
        public bool PlayState
        {
            get => Player.play;
            set => Player.play = value;
        }

        /// <summary>
        /// 特效是否循环
        /// </summary>
        public bool Loop
        {
            get => Player.loop;
            set => Player.loop = value;
        }

        /// <summary>
        /// 特效播放多久
        /// </summary>
        public float Duration
        {
            get => Player.duration;
            set => Player.duration = Mathf.Max(value, 0.1f);
        }

        /// <summary>
        /// 特效播放 延迟多久再次循环播放
        /// </summary>
        public float LoopDelay
        {
            get => Player.loopDelay;
            set => Player.loopDelay = Mathf.Max(value, 0);
        }

        /// <summary>
        /// 特效的播放时间方式
        /// </summary>
        public AnimatorUpdateMode UpdateMode
        {
            get => Player.updateMode;
            set => Player.updateMode = value;
        }

        /// <summary>
        /// 注册事件  得到动画播放的进度
        /// </summary>
        protected override void OnEnable()
        {
            base.OnEnable();
            Player.OnEnable(f => EffectFactor = f);
        }

        /// <summary>
        /// 注销事件
        /// </summary>
        protected override void OnDisable()
        {
            Player.OnDisable();
            base.OnDisable();
        }

        /// <summary>
        /// 播放特效
        /// </summary>
        public virtual void Play()
        {
            Player.Play();
        }

        /// <summary>
        /// 暂停特效
        /// </summary>
        public virtual void Stop()
        {
            Player.Stop();
        }

        /// <summary>
        /// 重置暂停
        /// </summary>
        public virtual void ResetAndStop()
        {
            EffectFactor = 0;
            Stop();
        }

        /// <summary>
        /// 重置暂停
        /// </summary>
        public virtual void LoopAndPlay()
        {
            Loop = true;
            Play();
        }
    }
}