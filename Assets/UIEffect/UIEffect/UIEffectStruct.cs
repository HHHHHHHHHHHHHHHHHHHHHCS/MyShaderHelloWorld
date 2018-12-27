namespace UIEffect
{
    /// <summary>
    /// 特效英雄模式
    /// </summary>
    public enum EffectMode
    {
        None = 0,//无
        Grayscale,//取灰度模式
        Sepia,//古老照片模式
        Nega,//反色
        Pixel,//像素化
    }


    /// <summary>
    /// 模糊模式
    /// </summary>
    public enum BlurMode
    {
        None = 0,//无
        FastBlur,//快速模糊
        MediumBlur,//中等模糊
        DetailBlur,//细节模糊
    }
}