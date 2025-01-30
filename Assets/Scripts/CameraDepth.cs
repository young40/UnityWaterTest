using System;
using UnityEngine;

public class CameraDepth : MonoBehaviour
{
    [SerializeField] private DepthTextureMode depthTextureMode;

    private void Awake()
    {
        //GetComponent<Camera>().depthTextureMode = depthTextureMode;
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(200, 200, 50, 50), "AAAA"))
        {
            GetComponent<Camera>().depthTextureMode = depthTextureMode;
        }

        if (GUI.Button(new Rect(400, 200, 50, 50), "BBBB"))
        {
            GetComponent<Camera>().depthTextureMode = DepthTextureMode.None;
        }
    }
}