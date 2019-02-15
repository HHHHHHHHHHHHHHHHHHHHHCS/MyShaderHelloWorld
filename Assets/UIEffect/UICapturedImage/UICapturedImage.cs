using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 捕获图片
    /// </summary>
    public class UICapturedImage : RawImage
    {
        private const string shaderName = "UI/S_UICapturedImage";


        private static int copyId = Shader.PropertyToID("_UIEffectCapture_ScreenCopyId"); //复制ID
        private static int effectId1 = Shader.PropertyToID("_UIEffectCapture_EffectId1"); //特效ID1
        private static int effectId2 = Shader.PropertyToID("_UIEffectCapture_EffectId2"); //特效ID2
        private static int effectFactorId = Shader.PropertyToID("_EffectFactor"); //特效进度ID
        private static int colorFactorId = Shader.PropertyToID("_ColorFactor"); //颜色进度ID
        private static CommandBuffer commandBuffer; //渲染命令

        private RenderTexture rt; //渲染后的图片
        private RenderTargetIdentifier rtId; //渲染的图片的ID

        /// <summary>
        /// 特效的播放进度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("特效的播放进度")]
        private float effectFactor = 1;

        /// <summary>
        /// 颜色播放进度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("颜色播放进度")]
        private float colorFactor = 1;

        /// <summary>
        /// 模糊的程度
        /// </summary>
        [Range(0, 1f), SerializeField, Tooltip("模糊的程度")]
        private float blurFactor = 1;

        /// <summary>
        /// 图片的影响模式
        /// </summary>
        [SerializeField, Tooltip("图片的影响模式")] private EffectMode effectMode = EffectMode.None;

        /// <summary>
        /// 颜色叠加模式
        /// </summary>
        [SerializeField, Tooltip("颜色叠加模式")] private ColorMode colorMode = ColorMode.Multiply;

        /// <summary>
        /// 模糊模式
        /// </summary>
        [SerializeField, Tooltip("模糊模式")] private BlurMode blurMode = BlurMode.DetailBlur;

        /// <summary>
        /// 特效的颜色
        /// </summary>
        [SerializeField, Tooltip("特效的颜色")] private Color effectColor = Color.white;

        /// <summary>
        /// 滤波采样率
        /// </summary>
        [SerializeField, Tooltip("滤波采样率")] private DesamplingRate desamplingRate = DesamplingRate.x1;

        /// <summary>
        /// 滤波去采样率
        /// </summary>
        [SerializeField, Tooltip("滤波去采样率")] private DesamplingRate reductionRate = DesamplingRate.x1;

        /// <summary>
        /// 滤波采样模式
        /// </summary>
        [SerializeField, Tooltip("滤波采样模式")] private FilterMode filterMode = FilterMode.Bilinear;

        /// <summary>
        /// 特效材质球
        /// </summary>
        [SerializeField, Tooltip("特效材质球")] private Material effectMaterial;

        /// <summary>
        /// 模糊倍率
        /// </summary>
        [Range(1, 8), SerializeField, Tooltip("模糊倍率")]
        private int blurIterations = 3;

        /// <summary>
        /// 是否填充屏幕
        /// </summary>
        [SerializeField, Tooltip("是否填充屏幕")] private bool fitToScreen = true;

        /// <summary>
        /// 是否Enable的时候就启动效果
        /// </summary>
        [SerializeField, Tooltip("是否Enable的时候就启动效果")]
        private bool captureOnEnable = false;

        /// <summary>
        /// 是否立即启动效果
        /// </summary>
        [SerializeField, Tooltip("是否立即启动效果")] private bool immediateCapturing = true;

        /// <summary>
        /// 特效的播放进度
        /// </summary>
        public float EffectFactor
        {
            get => effectFactor;
            set => effectFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 颜色播放进度
        /// </summary>
        public float ColorFactor
        {
            get => colorFactor;
            set => colorFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 模糊的程度
        /// </summary>
        public float BlurFactor
        {
            get => blurFactor;
            set => blurFactor = Mathf.Clamp01(value);
        }

        /// <summary>
        /// 图片的影响模式
        /// </summary>
        public EffectMode EffectMode => effectMode;

        /// <summary>
        /// 颜色叠加模式
        /// </summary>
        public ColorMode ColorMode => colorMode;

        /// <summary>
        /// 模糊模式
        /// </summary>
        public BlurMode BlurMode => blurMode;

        /// <summary>
        /// 特效的颜色
        /// </summary>
        public Color EffectColor => effectColor;

        /// <summary>
        /// 滤波采样率
        /// </summary>
        public DesamplingRate DesamplingRate => desamplingRate;

        /// <summary>
        /// 滤波去采样率
        /// </summary>
        public DesamplingRate ReductionRate => reductionRate;

        /// <summary>
        /// 滤波采样模式
        /// </summary>
        public FilterMode FilterMode => filterMode;

        /// <summary>
        /// 特效材质球
        /// </summary>
        public Material EffectMaterial => effectMaterial;

        /// <summary>
        /// 模糊倍率
        /// </summary>
        public int BlurIterations
        {
            get => blurIterations;
            set => blurIterations = Mathf.Clamp(value, 0, 8);
        }

        /// <summary>
        /// 是否填充屏幕
        /// </summary>
        public bool FitToScreen => fitToScreen;

        /// <summary>
        /// 是否Enable的时候就启动效果
        /// </summary>
        public bool CaptureOnEnable => captureOnEnable;

        /// <summary>
        /// 是否立即启动效果
        /// </summary>
        public bool ImmediateCapturing => immediateCapturing;

        /// <summary>
        /// 渲染后的图片
        /// </summary>
        public RenderTexture CapturedTexture => rt;

        /// <summary>
        /// 激活时候,根据是否激活播放来播放
        /// </summary>
        protected override void OnEnable()
        {
            base.OnEnable();
            if (captureOnEnable && Application.isPlaying)
            {
                Capture();
            }
        }

        /// <summary>
        /// 隐藏的时候,释放资源
        /// </summary>
        protected override void OnDisable()
        {
            base.OnDisable();
            if (captureOnEnable && Application.isPlaying)
            {
                Release(false);
                texture = null;
            }
        }

        /// <summary>
        /// 销毁的时候,释放资源
        /// </summary>
        protected override void OnDestroy()
        {
            Release();
            base.OnDestroy();
        }

        /// <summary>
        /// 重新设置顶点数据
        /// </summary>
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            if (texture == null || color.a < 1 / 255f || canvasRenderer.GetAlpha() < 1 / 255f)
            {
                //如果图片不可见,要么没有图片
                vh.Clear();
            }
            else
            {
                //设置顶点颜色,只要alpha
                base.OnPopulateMesh(vh);
                UIVertex vt = default;
                Color c = color;
                for (int i = 0; i < vh.currentVertCount; i++)
                {
                    vh.PopulateUIVertex(ref vt, i);
                    vt.color = c;
                    vh.SetUIVertex(vt, i);
                }
            }
        }

        /// <summary>
        /// 降低采样,得到宽高
        /// </summary>
        public void GetDesamplingSize(DesamplingRate rate, out int w, out int h)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                var res = UnityEditor.UnityStats.screenRes.Split('x');
                w = int.Parse(res[0]);
                h = int.Parse(res[1]);
            }
            else
#endif
            {
                w = Screen.width;
                h = Screen.height;

            }

            if (rate == DesamplingRate.None)
            {
                return;
            }

            float aspect = (float)w / h;

            //用2的开发图片,进行降低采样
            if (w < h)
            {
                h = Mathf.ClosestPowerOfTwo(h / (int) rate); //ClosestPowerOfTwo:返回离val最近的2的平方
                w = Mathf.CeilToInt(h * aspect);
            }
            else
            {
                w = Mathf.ClosestPowerOfTwo(w / (int) rate);
                h = Mathf.CeilToInt(w / aspect);
            }
        }

        /// <summary>
        /// 雕塑效果
        /// </summary>
        public void Capture()
        {
            var rootCanvas = canvas.rootCanvas;

            if (fitToScreen)
            {
                //是否全屏效果
                var rootTransform = rootCanvas.transform as RectTransform;
                var size = rootTransform.rect.size;
                rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, size.x);
                rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, size.y);
                rectTransform.position = rootTransform.position;
            }


            //w,h不符合不一致 ,释放重新创建
            GetDesamplingSize(desamplingRate, out var w, out var h);
            if (rt && (rt.width != w || rt.height != h))
            {
                Release(ref rt);
            }

            if (!rt||!rt.IsCreated())
            {
                //重新创建图片
                //w,h,缓存模版位数,图片格式,写入读取图片的颜色空间
                rt = RenderTexture.GetTemporary(w, h, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
                rt.filterMode = filterMode;
                rt.useMipMap = false;
                rt.wrapMode = TextureWrapMode.Clamp;
                rtId = new RenderTargetIdentifier(rt);
                
            }


            SetupCommandBuffer();
        }


        //设置渲染命令
        private void SetupCommandBuffer()
        {
            //设置材质球
            Material mat = effectMaterial;
            //渲染命令实例化
            if (commandBuffer == null)
            {
                commandBuffer = new CommandBuffer();
            }

            //设置原图
            GetDesamplingSize(DesamplingRate.None, out int w, out int h);
            commandBuffer.GetTemporaryRT(copyId, w, h, 0, filterMode);
#if UNITY_EDITOR
            commandBuffer.Blit(
                Resources.FindObjectsOfTypeAll<RenderTexture>().FirstOrDefault(x => x.name == "GameView RT"), copyId);
#else
            commandBuffer.Blit(BuiltinRenderTextureType.BindableTexture, copyId);
#endif

            //设置播放进度和颜色
            commandBuffer.SetGlobalVector(effectFactorId, new Vector4(effectFactor, 0));
            commandBuffer.SetGlobalVector(colorFactorId,
                new Vector4(effectColor.r, effectColor.g, effectColor.b, effectColor.a));
            
            //得到降低采样的图片
            GetDesamplingSize(reductionRate, out w, out h);
            commandBuffer.GetTemporaryRT(effectId1, w, h, 0, filterMode);
            commandBuffer.Blit(copyId, effectId1, mat, 0);
            commandBuffer.ReleaseTemporaryRT(copyId);

            //设置模糊图片,根据模糊次数多次effectId1->effectId2 或者 effectId1->effectId2
            if (blurMode != BlurMode.None)
            {
                commandBuffer.GetTemporaryRT(effectId2, w, h, 0, FilterMode);
                for (int i = 0; i < blurIterations; i++)
                {
                    commandBuffer.SetGlobalVector(effectFactorId, new Vector4(blurFactor, 0));
                    commandBuffer.Blit(effectId1, effectId2, mat, 1);
                    commandBuffer.SetGlobalVector(effectFactorId, new Vector4(0, blurFactor));
                    commandBuffer.Blit(effectId2, effectId1, mat, 1);
                }

                commandBuffer.ReleaseTemporaryRT(effectId2);
            }

            //设置到原图
            commandBuffer.Blit(effectId1, rtId);
            commandBuffer.ReleaseTemporaryRT(effectId1);

#if UNITY_EDITOR
            //编辑器模式下
            //如果不是播放状态,直接更新特效图片,跳出
            //如果是播放状态,预先执行渲染命令,在根据是否立即更新而更新
            if (!Application.isPlaying)
            {
                Graphics.ExecuteCommandBuffer(commandBuffer);
                UpdateTexture();
                return;
            }

            Graphics.ExecuteCommandBuffer(commandBuffer);
#endif

            //正常模式,根据是否立即更新图片,执行渲染命再令更新图片,没有预先执行渲染命令
            if (immediateCapturing)
            {
                UpdateTexture();
            }
            else
            {
                canvas.rootCanvas.GetComponent<CanvasScaler>().StartCoroutine(CallUpdateTextureOnNextFrame());
            }
        }




        /// <summary>
        /// 释放
        /// </summary>
        public void Release()
        {
            Release(true);
            texture = null;
            SetDirty();
        }

        /// <summary>
        /// 设置自己要被清除
        /// </summary>
        private void SetDirty()
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                UnityEditor.EditorUtility.SetDirty(this);
            }
#endif
        }

        /// <summary>
        /// 释放图片,是否要释放RT
        /// </summary>
        private void Release(bool releaseRT)
        {
            if (releaseRT)
            {
                texture = null;
                Release(ref rt);
            }

            if (commandBuffer != null)
            {
                commandBuffer.Clear();
                if (releaseRT)
                {
                    commandBuffer.Release();
                    commandBuffer = null;
                }
            }
        }


        /// <summary>
        /// 释放RT
        /// </summary>
        private void Release(ref RenderTexture obj)
        {
            if (obj)
            {
                obj.Release();
                RenderTexture.ReleaseTemporary(obj);
                obj = null;
            }
        }

#if UNITY_EDITOR
        /// <summary>
        /// inspector点击Reset
        /// </summary>
        protected override void Reset()
        {
            blurIterations = 3;
            filterMode = FilterMode.Bilinear;
            desamplingRate = DesamplingRate.x1;
            reductionRate = DesamplingRate.x1;
            base.Reset();
        }

        /// <summary>
        /// 加载和修改数据的时候调用
        /// </summary>
        protected override void OnValidate()
        {
            base.OnValidate();
            UnityEditor.EditorApplication.delayCall += () => UpdateMaterial(false);
        }

        protected void UpdateMaterial(bool ignoreInPlayMode)
        {
            if (!this || ignoreInPlayMode && Application.isPlaying)
            {
                return;
            }

            var mat = MaterialResolver.GetOrGenerateMaterialVariant(Shader.Find(shaderName), effectMode, ColorMode,
                BlurMode);

            if (effectMaterial != mat)
            {
                material = null;
                effectMaterial = mat;
                SetDirty();
            }
        }
#endif

        /// <summary>
        /// 延迟一帧更新图片
        /// </summary>
        private IEnumerator CallUpdateTextureOnNextFrame()
        {
            yield return new WaitForEndOfFrame();
            UpdateTexture();
        }

        /// <summary>
        /// 立即更新图片
        /// Editor下,渲染命令被外部预先执行
        /// 正常是执行渲染命令,释放图片,设置图片,设置清除数据
        /// </summary>
        private void UpdateTexture()
        {
#if !UNITY_EDITOR
            Graphics.ExecuteCommandBuffer(commandBuffer);
#endif
            Release(false);
            texture = CapturedTexture;
            SetDirty();
        }
    }
}