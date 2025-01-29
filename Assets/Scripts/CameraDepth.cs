using System;
using UnityEngine;

public class CameraDepth : MonoBehaviour
{
    [SerializeField] private DepthTextureMode depthTextureMode;

    private void Awake()
    {
        GetComponent<Camera>().depthTextureMode = depthTextureMode;
    }
}