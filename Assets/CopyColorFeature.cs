using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CopyColorFeature : ScriptableRendererFeature
{
    private CopyColorPass pass;
    
    public override void Create()
    {
        pass = new CopyColorPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(pass);
    }
}
