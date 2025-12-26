Shader "My/Water Shader"
{
    Properties
    {
        _DepthGradientShallow("Depth Gradient Shallow", Color) =  (0.325, 0.807, 0.971, 0.725) // 浅水颜色
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749) // 深水颜色
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1 // 水的最深距离, 超过此则都显示 深水颜色
        
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise CutOff", Range(0, 1)) = 0.77
        
        _FoamMaxDistance("Foam Max Distance", Float) = 0.4
        _FoamMinDistance("Foam Min Distance", Float) = 0.04
        
        _SurfaceNoiseScroll("Surface Noise Scroll", Float) = (0.3, 0.3, 0, 0)
        
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27
        
        _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 nosizeUV : TEXCOORD0;
                float2 distorUV : TEXCOORD1;
                float4 screenPosition : TEXCOORD2;
                float3 viewNormal : NORMAL;
            };
            
            float _SurfaceNoiseCutoff;
            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;
            
            float _FoamMaxDistance;
            float _FoamMinDistance;
            
            float2 _SurfaceNoiseScroll;
            
            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            
            float _SurfaceDistortionAmount;
            
            float4 _FoamColor;
            
            float4 alphaBlend(float4 top, float4 bottom)
            {
                float3 color = top.rgb * top.a + bottom.rgb * (1 - top.a);
                float alpha = top.a + bottom.a * (1 - top.a);
                
                return float4(color, alpha);
            }
            
            v2f vertex(appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.nosizeUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distorUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                o.viewNormal = COMPUTE_VIEW_NORMAL;
                
                return o;
            }
            
            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            
            sampler2D _CameraDepthTexture;
            
            sampler2D _CameraNormalsTexture;
            
            float4 fragment(v2f i) : SV_TARGET
            {
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                
                float depthDifference = existingDepthLinear - i.screenPosition.w;
                
                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
                
                float2 distorSample = (tex2D(_SurfaceDistortion, i.distorUV).xy * 2 - 1) * _SurfaceDistortionAmount;
                
                float2 noiseUV = float2(i.nosizeUV.x + _Time.y * _SurfaceNoiseScroll.x + distorSample.x,
                                        i.nosizeUV.y + _Time.y * _SurfaceNoiseScroll.y + distorSample.y);
                
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;
                
                float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
                float normalDot = saturate(dot(existingNormal, i.viewNormal));
                
                float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
                
                float foamDepthDifference01 = saturate(depthDifference / foamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                
                //float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;
                float surfaceNoise = smoothstep(surfaceNoiseCutoff - 0.01, surfaceNoiseCutoff + 0.01, surfaceNoiseSample);
                
                float4 surfaceNoiseColor = _FoamColor;
                surfaceNoiseColor.a *= surfaceNoise;
                
                return alphaBlend(surfaceNoiseColor, waterColor); // waterColor + surfaceNoiseColor;
            }
            ENDCG
        }
    }
}