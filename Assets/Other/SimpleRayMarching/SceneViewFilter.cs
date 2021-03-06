﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;

#endif

public class SceneViewFilter : MonoBehaviour
{
#if UNITY_EDITOR
    public static bool _syncCamera = true;

    public bool sync = true;

    private bool hasChanged = false;

    static SceneViewFilter()
    {
        SceneView.duringSceneGui += CheckMe;
    }

    public virtual void OnValidate()
    {
        _syncCamera = sync;
        hasChanged = true;
    }

    public static void CheckMe(SceneView sv)
    {
        if (Event.current.type != EventType.Layout)
            return;
        if (!Camera.main)
            return;

        if (_syncCamera)
        {
            Camera.main.transform.SetPositionAndRotation(
                sv.camera.transform.position, sv.camera.transform.rotation);
        }


        SceneViewFilter[] cameraFilters = Camera.main.GetComponents<SceneViewFilter>();
        SceneViewFilter[] sceneFilters = sv.camera.GetComponents<SceneViewFilter>();

        if (cameraFilters.Length != sceneFilters.Length)
        {
            ReCreate(sv);
            return;
        }

        for (int i = 0; i < cameraFilters.Length; i++)
        {
            if (cameraFilters[i].hasChanged || sceneFilters[i].enabled != cameraFilters[i].enabled)
            {
                EditorUtility.CopySerialized(cameraFilters[i], sceneFilters[i]);
                cameraFilters[i].hasChanged = false;
            }
        }
    }

    public static void ReCreate(SceneView sv)
    {
        SceneViewFilter filter;
        foreach (var item in sv.camera.GetComponents<SceneViewFilter>())
        {
            DestroyImmediate(item);
        }

        foreach (var item in Camera.main.GetComponents<SceneViewFilter>())
        {
            SceneViewFilter newFilter = sv.camera.gameObject.AddComponent(item.GetType()) as SceneViewFilter;
            EditorUtility.CopySerialized(item, newFilter);
        }
    }
#endif
}