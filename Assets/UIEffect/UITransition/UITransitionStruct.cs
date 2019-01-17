using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UIEffect
{
    public enum TransitionMode
    {
        None = 0, //无效果
        Fade, //alpha退去
        Cutoff, //剪切
        Dissolve, //溶解
    }
}