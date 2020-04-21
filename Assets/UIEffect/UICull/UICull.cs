using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UICull : MonoBehaviour
{
    private void Awake()
    {
        Image image = GetComponent<Image>();
        //普通的无Mask/RectMask用下面API不渲染的效果
        //image.canvasRenderer.cull = true;
        //RectMask2D 和 Mask  都有区域裁剪功能
        //Mask不会裁剪区域外的UI对象有多少 渲染多少
        //RectMask 只会渲染内部元素
    }

}
