using UnityEngine;

public class ReplaceShader : MonoBehaviour
{
    [SerializeField]
    private RenderTexture renderTexture;

    [SerializeField] 
    private Shader normalShader;
    
    private new Camera _camera;

    private void Start()
    {
        Camera thisCamera = GetComponent<Camera>();

        renderTexture = new RenderTexture(_camera.pixelWidth, _camera.pixelHeight, 24);
        
        Shader.SetGlobalTexture("_CameraNormalsTexture", renderTexture);

        GameObject copy = new GameObject("Normals camera");
        _camera = copy.AddComponent<Camera>();
        _camera.CopyFrom(thisCamera);
        
        _camera.targetTexture = renderTexture;
        _camera.targetTexture = renderTexture;
        _camera.SetReplacementShader(normalShader, "RenderType");
        _camera.depth = thisCamera.depth - 1;
    }
}
