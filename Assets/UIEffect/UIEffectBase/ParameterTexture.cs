using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
        int parameterIndex { get; set; } 

        /// <summary>
        /// 参数的图片
        /// </summary>
        ParameterTexture ParaTex { get; }
    }

    /// <summary>
    /// 参数图片
    /// </summary>
    [System.Serializable]
    public class ParameterTexture
    {
        private static List<Action> updateList; //图片要更新的事件

        private readonly string propertyName; //shader texture的name
        private readonly int channels; //一个特效组 可以有几个对象 4的倍数
        private readonly int instanceLimit; //最多有几个特效组

        private int propertyId; //shader texture的id
        private Texture2D texture; //当前的图片
        private bool needUpdate; //是否要更新图片
        private byte[] data; //图片数据
        private Stack<int> stack; //对象池 缓存池

        /// <summary>
        /// 构造参数图片
        /// </summary>
        /// <param name="_channels">一组有几个特效</param>
        /// <param name="_instanceLimit">有几个特效组</param>
        /// <param name="_propertyName">shader texture的名字</param>
        public ParameterTexture(int _channels, int _instanceLimit, string _propertyName)
        {
            propertyName = _propertyName;
            channels = ((channels - 1) / 4 + 1) * 4; //4的倍数
            instanceLimit = ((instanceLimit - 1) / 2 + 1) * 2; //2的倍数
            data = new byte[channels * instanceLimit];
            stack = new Stack<int>(instanceLimit);
            for (var i = 1; i < instanceLimit + 1; i++)
            {
                stack.Push(i);
            }
        }

        /// <summary>
        /// 初始化参数图片 和 参数图片改变事件
        /// </summary>
        private void Initialize()
        {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying || UnityEditor.EditorApplication.isPlayingOrWillChangePlaymode)
            {
                return;
            }
#endif
            if (updateList == null)
            {
                updateList = new List<Action>();
                Canvas.willRenderCanvases += () =>
                {
                    foreach (var act in updateList)
                    {
                        act();
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
        /// <param name="target"></param>
        public void Register(IParameterTexture target)
        {
            Initialize();
            if (target.parameterIndex <= 0 && stack.Count > 0)
            {
                target.parameterIndex = stack.Pop();
            }
        }

        /// <summary>
        /// 注销一个参数图片
        /// </summary>
        /// <param name="target"></param>
        public void Unregister(IParameterTexture target)
        {
            if (target.parameterIndex > 0)
            {
                stack.Push(target.parameterIndex);
                target.parameterIndex = 0;
            }
        }

        /// <summary>
        /// 数值参数图片数据
        /// </summary>
        /// <param name="target"></param>
        /// <param name="channelId"></param>
        /// <param name="value"></param>
        public void SetData(IParameterTexture target, int channelId, byte value)
        {
            //如果在缓存池就不用更新了
            if (target.parameterIndex <= 0)
            {
                return;
            }

            int index = (target.parameterIndex - 1) * channels + channelId;
            //数据没有改变不用更新
            if (data[index] != value)
            {
                data[index] = value;
                needUpdate = true;
            }
        }

        /// <summary>
        /// 设置参数图片数据
        /// </summary>
        /// <param name="target"></param>
        /// <param name="channelId"></param>
        /// <param name="value"></param>
        public void SetData(IParameterTexture target, int channelId, float value)
        {
            SetData(target, channelId, (byte) (Mathf.Clamp01(value) * 255));
        }

        /// <summary>
        /// 设置材质球的图片
        /// </summary>
        /// <param name="mat"></param>
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
        /// 得到标准化索引
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public float GetNormalizedIndex(IParameterTexture target)
        {
            return ((float)target.parameterIndex - 0.5f) / instanceLimit;
        }
    }
}