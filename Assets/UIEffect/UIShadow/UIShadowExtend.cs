using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UIEffect
{
    /// <summary>
    /// 外轮廓的效果用
    /// </summary>
    public enum ShadowStyle
    {
        None = 0,//没有效果
        Shadow,//1次阴影,性能最好
        Shadow3,//3次阴影,性能较好
        Outline,//4次阴影,性能中
        Outline8,//8次阴影,性能最差

    }
}

