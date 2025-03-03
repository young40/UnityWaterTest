using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class CopyColorPass : ScriptableRenderPass
{
    private class PassData
    {
        internal TextureHandle copySourceTexture;
    }

    static void ExecutePass(PassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, data.copySourceTexture, new Vector4(1, 1, 0, 0), 0, false);
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        using (var builder = renderGraph.AddRasterRenderPass<PassData>("Copy to Debug Texture222", out var passData))
        {
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            passData.copySourceTexture = resourceData.activeColorTexture;
            
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

            RenderTextureDescriptor desc = cameraData.cameraTargetDescriptor;
            desc.msaaSamples = 1;
            desc.depthBufferBits = 0;

            TextureHandle destination = UniversalRenderer.CreateRenderGraphTexture(renderGraph, desc, "CopppTexture", false);
            
            builder.UseTexture(passData.copySourceTexture);
            
            builder.UseTexture(destination, 0);
            
            builder.AllowPassCulling(false);

            builder.SetRenderFunc((PassData data, RasterGraphContext context) => ExecutePass(data, context));
        }
    }
}