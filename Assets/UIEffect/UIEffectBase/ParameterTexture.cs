using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System;

namespace UIEffect
{
    /// <summary>
    /// 参数图片接口
    /// </summary>
    public interface IParameterTexture
    {
        /// <summary>
        /// 特效的索引
        /// </summary>
        int ParameterIndex { get; set; }

        /// <summary>
        /// 参数的图片
        /// </summary>
        ParameterTexture ParamTex { get; }
    }

    /// <summary>
    /// 参数图片
    /// </summary>
    [System.Serializable]
    public class ParameterTexture
    {
        private static List<Action> updateList; //图片要更新的事件

        private readonly string propertyName; //shader参数 texture的name
        private readonly int channels; //一组有几个参数 4的倍数(rgba)
        private readonly int instanceLimit; //最多几个特效组
        private readonly byte[] data; //图片数据
        private readonly Stack<int> effectStack; //对象池 缓存池

        private int propertyId; //shader参数 texture的id
        private Texture2D texture; //图片数据
        private bool needUpdate; //是否要更新图片


        /// <summary>
        /// 构造参数图片
        /// </summary>
        /// <param name="_channels">一组有几个特效参数</param>
        /// <param name="_instanceLimit">有几个特效组</param>
        /// <param name="_propertyName">shader texture的名字</param>
        public ParameterTexture(int _channels, int _instanceLimit, string _propertyName)
        {
            propertyName = _propertyName;
            channels = ((_channels - 1) / 4 + 1) * 4;
            instanceLimit = ((_instanceLimit - 1) / 2 + 1) * 2;
            data = new byte[channels * instanceLimit];

            effectStack = new Stack<int>(instanceLimit);
            for (int i = 1; i < instanceLimit + 1; i++)
            {
                effectStack.Push(i);
            }
        }


        /// <summary>
        /// 初始化参数图片 和 参数图片改变事件
        /// </summary>
        private void Initialize()
        {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying && UnityEditor.EditorApplication.isPlayingOrWillChangePlaymode)
            {
                return;
            }
#endif
            if (updateList == null)
            {
                updateList = new List<Action>();
                Canvas.willRenderCanvases += () =>
                {
                    var count = updateList.Count;
                    for (int i = 0; i < count; i++)
                    {
                        updateList[i].Invoke();
                    }
                };
            }

            if (!texture)
            {
                texture = new Texture2D(channels / 4, instanceLimit, TextureFormat.RGBA32, false, false)
                {
                    filterMode = FilterMode.Point,
                    wrapMode = TextureWrapMode.Clamp
                };

                updateList.Add(UpdateParameterTexture);
            }
        }


        /// <summary>
        /// 参数图片改变事件
        /// </summary>
        private void UpdateParameterTexture()
        {
            if (needUpdate && texture)
            {
                needUpdate = false;
                texture.LoadRawTextureData(data);
                texture.Apply(false, false);
            }
        }

        /// <summary>
        /// 注册一个参数图片
        /// </summary>
        public void Register(IParameterTexture target)
        {
            Initialize();
            if (target.ParameterIndex <= 0 && 0 < effectStack.Count)
            {
                target.ParameterIndex = effectStack.Pop();
            }
        }

        /// <summary>
        /// 注销一个参数图片
        /// </summary>
        public void Unregister(IParameterTexture target)
        {
            if (0 < target.ParameterIndex)
            {
                effectStack.Push(target.ParameterIndex);
                target.ParameterIndex = 0;
            }
        }

        /// <summary>
        /// 数值参数图片数据
        /// </summary>
        /// <param name="target">目标</param>
        /// <param name="channelId">参数位置</param>
        /// <param name="value">参数值值</param>
        public void SetData(IParameterTexture target, int channelId, byte value)
        {
            //如果在缓存池就不用更新了
            if (target.ParameterIndex <= 0)
            {
                return;
            }

            int index = (target.ParameterIndex - 1) * channels + channelId;

            //数据没有改变不用更新
            if (data[index] != value)
            {
                data[index] = value;
                needUpdate = true;
            }
        }

        /// <summary>
        /// 设置参数图片数据 value:(在0-1之间 会被扩展到0-255)
        /// </summary>
        /// <param name="target">目标</param>
        /// <param name="channelId">参数位置</param>
        /// <param name="value">参数值(在0-1之间 会被扩展到0-255)</param>
        public void SetData(IParameterTexture target, int channelId, float value)
        {
            SetData(target, channelId, (byte) (Mathf.Clamp01(value) * 255));
        }

        /// <summary>
        /// 设置材质球的图片
        /// </summary>
        public void RegisterMaterial(Material mat)
        {
            if (propertyId == 0)
            {
                propertyId = Shader.PropertyToID(propertyName);
            }

            if (mat)
            {
                mat.SetTexture(propertyId, texture);
            }
        }

        /// <summary>
        /// 得到索引(在0-1之间的),在UV用
        /// </summary>
        public float GetNormalizedIndex(IParameterTexture target)
        {
            return (target.ParameterIndex - 0.5f) / instanceLimit;
        }
    }
}