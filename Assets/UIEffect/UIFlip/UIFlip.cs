using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace UIEffect
{
    /// <summary>
    /// 图片简单变化
    /// </summary>
    [RequireComponent(typeof(Graphic)), DisallowMultipleComponent]
    public class UIFlip : BaseMeshEffect
    {
        /// <summary>
        /// 左右翻转
        /// </summary>
        [SerializeField, Tooltip("左右翻转")] private bool horizontal = false;

        /// <summary>
        /// 垂直翻转
        /// </summary>
        [SerializeField, Tooltip("垂直翻转")] private bool vertical = false;

        /// <summary>
        /// 旋转角度
        /// </summary>
        [SerializeField, Tooltip("旋转角度")] private float rotation = 0;

        /// <summary>
        /// 偏移顶点
        /// </summary>
        [SerializeField, Tooltip("偏移顶点")] private Vector2 offsetPos = Vector2.zero;

        /// <summary>
        /// 左右翻转
        /// </summary>
        public bool Horizontal => horizontal;

        /// <summary>
        /// 垂直翻转
        /// </summary>
        public bool Vertical => vertical;

        /// <summary>
        /// 旋转角度
        /// </summary>
        public float Rotation => rotation;

        /// <summary>
        /// 偏移顶点
        /// </summary>
        public Vector2 OffsetPos => offsetPos;

        /// <summary>
        /// 修改顶点
        /// </summary>
        /// <param name="vh"></param>
        public override void ModifyMesh(VertexHelper vh)
        {
            //RectTransform rt = graphic.rectTransform;
            UIVertex vt = default;
            Vector3 pos;
            //Vector2 center = rt.rect.center;
            var d2r = rotation * Mathf.Deg2Rad;
            float cosAngle = Mathf.Cos(d2r);
            float sinAngle = Mathf.Sin(d2r);
            for (int i = 0; i < vh.currentVertCount; i++)
            {
                vh.PopulateUIVertex(ref vt, i);
                pos = vt.position;
                pos.x = offsetPos.x + (horizontal ? -pos.x : pos.x);
                pos.y = offsetPos.y + (vertical ? -pos.y : pos.y);
                Vector3 tempPos = pos;
                pos.x = tempPos.x * cosAngle - tempPos.y * sinAngle;
                pos.y = tempPos.x * sinAngle + tempPos.y * cosAngle;
                vt.position = pos;
                vh.SetUIVertex(vt, i);
            }
        }
    }
}