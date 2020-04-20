using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClickObj : MonoBehaviour
{
    public enum ObjType
    {
        None,
        Pyramid,
        Trillion,
        Diamond,
    }

    public static List<ClickObj> clickObjs = new List<ClickObj>();

    public ObjType objType = ObjType.None;

    public bool isClick = false;

    public Action clickAct;
    public Action cancelAct;


    private void Awake()
    {
        clickObjs.Add(this);
        RegisterClickAct();
        RegisterCancelAct();
    }

    private void OnMouseUpAsButton()
    {
        OnClick();
    }

    private void OnClick()
    {
        if (!isClick)
        {
            foreach (var item in clickObjs)
            {
                item.OnCancel();
            }

            isClick = true;
            clickAct?.Invoke();
        }
    }

    private void OnCancel()
    {
        if (isClick)
        {
            isClick = false;
            cancelAct?.Invoke();
        }
    }

    private void RegisterClickAct()
    {
        switch (objType)
        {
            case ObjType.None:
                break;
            case ObjType.Pyramid:
                clickAct += PyramidClickAct;
                break;
            case ObjType.Trillion:
                clickAct += TrillionClickAct;
                break;
            case ObjType.Diamond:
                clickAct += DiamondClickAct;
                break;
        }
    }


    private void RegisterCancelAct()
    {
        switch (objType)
        {
            case ObjType.None:
                break;
            case ObjType.Pyramid:
                cancelAct += PyramidCancelAct;
                break;
            case ObjType.Trillion:
                cancelAct += TrillionCancelAct;
                break;
            case ObjType.Diamond:
                cancelAct += DiamondCancelAct;
                break;
        }
    }

    private void PyramidClickAct()
    {
        Debug.Log(1);
        Camera.main.GetComponent<RayTrace>().SetMagicAlpha(1.0f);
    }

    private void PyramidCancelAct()
    {
        Debug.Log(0);

        Camera.main.GetComponent<RayTrace>().SetMagicAlpha(0.0f);
    }

    private void TrillionClickAct()
    {
        var revertObj = GetComponent<RevertObj>();
        if (revertObj)
        {
            revertObj.enabled = true;
        }
    }

    private void TrillionCancelAct()
    {
        var revertObj = GetComponent<RevertObj>();
        if (revertObj)
        {
            revertObj.enabled = false;
        }
    }

    private void DiamondClickAct()
    {
        var revertObj = GetComponent<RevertObj>();
        if (revertObj)
        {
            revertObj.enabled = true;
        }
    }

    private void DiamondCancelAct()
    {
        var revertObj = GetComponent<RevertObj>();
        if (revertObj)
        {
            revertObj.enabled = false;
        }
    }
}
