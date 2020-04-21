using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UIEmptyClick : Graphic, IPointerDownHandler
    , IPointerUpHandler
{
    public override void SetMaterialDirty()
    {
    }

    public override void SetVerticesDirty()
    {
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();
    }


    public void OnPointerUp(PointerEventData eventData)
    {
        Debug.Log("OnPointerUp");
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        Debug.Log("OnPointerDown");
    }
}