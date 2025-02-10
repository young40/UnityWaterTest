Shader "Custom/ToonWater"
{
    Properties
    {
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
        
        _FoamDistance("Foam Distance", Float) = 0.4
        
        _SurfaceNoiseScroll("Surface Noise Scroll", Vector) = (0.03, 0.03, 0, 0)
        
        _SurfaceDistortion("Surface Distortion", 2D) ="white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Float) = 0.27
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;

                float2 noiseUV : TEXCOORD0;

                float2 distortUV : TEXCOORD1;
            };

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;

            float _DepthMaxDistance;

            float _SurfaceNoiseCutoff;

            float _FoamDistance;

            float2 _SurfaceNoiseScroll;

            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);

            TEXTURE2D(_SurfaceNoise);
            SAMPLER(sampler_SurfaceNoise);
            float4 _SurfaceNoise_ST;

            TEXTURE2D(_SurfaceDistortion);
            SAMPLER(sampler_SurfaceDistortion);
            float4 _SurfaceDistortion_ST;

            float _SurfaceDistortionAmount;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half2 uv = i.screenPosition.xy / i.screenPosition.w;

                float exitingDepth01 = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;

                float existingDepthLinear = LinearEyeDepth(exitingDepth01, _ZBufferParams);

                float depthDifference = existingDepthLinear - i.screenPosition.w;

                float waterDepthDifference = saturate(depthDifference / _DepthMaxDistance);

                float4 color = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference);

                float2 distortSample = (SAMPLE_TEXTURE2D(_SurfaceDistortion, sampler_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;

                float2 noiseUV = float2((i.noiseUV.x + _Time.x * _SurfaceNoiseScroll.x) + distortSample.x,
                    (i.noiseUV.y + _Time.x * _SurfaceNoiseScroll.y) + distortSample.y);

                float noise = SAMPLE_TEXTURE2D(_SurfaceNoise, sampler_SurfaceNoise, noiseUV).r;

                float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

                float surfaceNoise = noise > surfaceNoiseCutoff ? 1 : 0;

                return color + surfaceNoise;
            }
            ENDHLSL
        }
    }
}