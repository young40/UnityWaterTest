using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class BlurRenderPass : ScriptableRenderPass
{
    private readonly BlurSettings defaultSettings;
    private readonly Material material;

    private RenderTextureDescriptor blurTextureDescriptor;

    private static readonly int horizontalBlurId = Shader.PropertyToID("_HorizontalBlur");
    private static readonly int verticalBlurId = Shader.PropertyToID("_VerticalBlur");
    private const string k_BlurTextureName = "_BlurTextureXXXXXXX";
    private const string k_VerticalPassName = "VerticalBlurRenderPass";
    private const string k_HorizontalPassName = "HorizontalBlurRenderPass";

    public BlurRenderPass(Material material, BlurSettings defaultSettings)
    {
        this.defaultSettings = defaultSettings;
        this.material = material;

        blurTextureDescriptor = new RenderTextureDescriptor(Screen.width, Screen.height, RenderTextureFormat.Default, 0);
    }


    private void UpdateBlurSettings()
    {
        if (material == null) return;

        // Use the Volume settings or the default settings if no Volume is set.
        var volumeComponent = VolumeManager.instance.stack.GetComponent<CustomVolumeComponent>();

        var horizontalBlur = volumeComponent.horizontalBlur.overrideState ? volumeComponent.horizontalBlur.value : defaultSettings.horizontalBlur;

        var verticalBlur = volumeComponent.verticalBlur.overrideState ? volumeComponent.verticalBlur.value : defaultSettings.verticalBlur;

        material.SetFloat(horizontalBlurId, horizontalBlur);
        material.SetFloat(verticalBlurId, verticalBlur);
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        base.RecordRenderGraph(renderGraph, frameData);

        var resourceData = frameData.Get<UniversalResourceData>();

        var cameraData = frameData.Get<UniversalCameraData>();

        // The following line ensures that the render pass doesn't blit
        // from the back buffer.
        if (resourceData.isActiveTargetBackBuffer)
        {
            return;
        }

        // Set the blur texture size to be the same as the camera target size.
        blurTextureDescriptor.width = cameraData.cameraTargetDescriptor.width;
        blurTextureDescriptor.height = cameraData.cameraTargetDescriptor.height;
        blurTextureDescriptor.depthBufferBits = 0;

        var srcCamColor = resourceData.activeColorTexture;
        var dst = UniversalRenderer.CreateRenderGraphTexture(renderGraph, blurTextureDescriptor, k_BlurTextureName, false);

        // Update the blur settings in the material
        UpdateBlurSettings();

        // This check is to avoid an error from the material preview in the scene
        if (!srcCamColor.IsValid() || !dst.IsValid())
        {
            return;
        }

        // The AddBlitPass method adds a vertical blur render graph pass that blits from the source texture (camera color in this case) to the destination texture using the first shader pass (the shader pass is defined in the last parameter).
        RenderGraphUtils.BlitMaterialParameters paraVertical = new(srcCamColor, dst, material, 0);
        renderGraph.AddBlitPass(paraVertical, k_VerticalPassName);

        // The AddBlitPass method adds a horizontal blur render graph pass that blits from the texture written by the vertical blur pass to the camera color texture. The method uses the second shader pass.
        RenderGraphUtils.BlitMaterialParameters paraHorizontal = new(dst, srcCamColor, material, 1);
        renderGraph.AddBlitPass(paraHorizontal, k_HorizontalPassName);
    }
}