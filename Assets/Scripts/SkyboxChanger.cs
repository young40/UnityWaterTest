using System;
using System.Collections;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

public class SkyboxChanger : MonoBehaviour
{
    [SerializeField] private Material[] skyboxes;

    private void Start()
    {
        UpdateSkybox(0);
        StartCoroutine(ChangeSkybox());
    }

    private IEnumerator ChangeSkybox()
    {
        var currentIndex = 0;
        while (true)
        {
            yield return new WaitForSeconds(10f);
            currentIndex++;
            currentIndex %= skyboxes.Length;

            UpdateSkybox(currentIndex);
        }
    }

    private void UpdateSkybox(int index)
    {
        RenderSettings.skybox = skyboxes[index];
    }

#if  UNITY_EDITOR
    private void OnValidate()
    {
        if (skyboxes.Length != 0)
        {
            return;
        }

        var materials = AssetDatabase.FindAssets("t:Material");

        List<Material> list = new List<Material>();

        foreach (var material in materials)
        {
            string path = AssetDatabase.GUIDToAssetPath(material);
            if (path.Contains("Skybox"))
            {
                list.Add(AssetDatabase.LoadAssetAtPath<Material>(path));
            }
        }

        skyboxes = list.ToArray();
    }
#endif
}