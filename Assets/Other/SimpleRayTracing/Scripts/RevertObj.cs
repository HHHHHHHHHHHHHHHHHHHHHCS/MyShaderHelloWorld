using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class RevertObj : MonoBehaviour
{

    public float revertTime = 3f;

    public bool endPlayAnim = true;

    public bool startMark = true;

    public bool revertPos;
    public Vector3 toPosition = Vector3.zero;
    public bool revertRot;
    public Vector3 toRotation = Vector3.zero;
    public bool revertSca;
    public Vector3 toScale = Vector3.one;

    private float nowTime;
    private Vector3 startPos;
    private Quaternion startRot;
    private Vector3 startSca;

    private bool isKinematic;

    private void Awake()
    {
        if (startMark)
        {
            toPosition = transform.position;
            toRotation = transform.rotation.eulerAngles;
            toScale = transform.localScale;
        }
    }

    private void OnEnable()
    {
        nowTime = 0f;
        startPos = transform.position;
        startRot = transform.rotation;
        startSca = transform.localScale;
        var rigi = GetComponent<Rigidbody>();
        if (rigi)
        {
            isKinematic = rigi.isKinematic;
            rigi.isKinematic = true;
        }
    }

    private void Update()
    {
        if (nowTime >= revertTime)
        {
            if (endPlayAnim)
            {
                EnableAnim(true);
            }
            return;
        }

        nowTime += Time.deltaTime;
        //nowTime = Mathf.Clamp(nowTime + Time.deltaTime, 0, revertTime);

        float percentage = revertTime == 0 ? 0 : nowTime / revertTime;

        if (revertPos)
        {
            transform.position = Vector3.Lerp(startPos, toPosition, percentage);
        }

        if (revertRot)
        {
            transform.rotation = Quaternion.Lerp(startRot, Quaternion.Euler(toRotation), percentage);
        }

        if (revertSca)
        {
            transform.localScale = Vector3.Lerp(startSca, toScale, percentage);
        }
    }

    private void OnDisable()
    {
        var rigi = GetComponent<Rigidbody>();
        if (rigi)
        {
            rigi.isKinematic = isKinematic;
        }

        if (endPlayAnim)
        {
            EnableAnim(false);
        }
    }

    private void EnableAnim(bool isEnable)
    {
        var anim = GetComponent<Animator>();
        if (anim)
        {
            anim.enabled = isEnable;
        }
    }
}