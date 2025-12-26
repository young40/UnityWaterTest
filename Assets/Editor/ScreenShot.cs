using UnityEngine;
using UnityEditor;
using System;
using System.IO;

public class ScreenShotEditor : EditorWindow
{
    [MenuItem("Tools/Take Game View Screenshot %&s")]
    static void TakeGameViewScreenshot()
    {
        // Get the current timestamp
        string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        
        // Create the Screenshots directory if it doesn't exist
        string screenshotsPath = Path.Combine(Application.dataPath, "Screenshots");
        if (!Directory.Exists(screenshotsPath))
        {
            Directory.CreateDirectory(screenshotsPath);
        }
        
        // Generate the filename with timestamp
        string fileName = $"Screenshot_{timestamp}.png";
        string fullPath = Path.Combine(screenshotsPath, fileName);
        
        // Capture the Game View
        ScreenCapture.CaptureScreenshot(fullPath);
        
        Debug.Log($"Screenshot saved to: {fullPath}");
        
        // Refresh the Asset Database so the screenshot appears in Unity
        AssetDatabase.Refresh();
        
        // Show a notification in the Unity editor
        EditorUtility.DisplayDialog("Screenshot Taken", $"Screenshot saved to: Assets/Screenshots/{fileName}", "OK");
    }
}