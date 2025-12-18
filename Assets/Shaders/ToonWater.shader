Shader "My/Water Shader"
{
    Properties
    {
        _DepthGradientShallow("Depth Gradient Shallow", Color) =  (0.325, 0.807, 0.971, 0.725) // 浅水颜色
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749) // 深水颜色
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1 // 水的最深距离, 超过此则都显示 深水颜色
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
            };
            
            v2f vertex(appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(v.vertex);
                
                return o;
            }
            
            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistant;
            
            sampler2D _CameraDepthTexture;
            
            float4 fragment(v2f i) : SV_TARGET
            {
                return float4(1, 0, 0, 1);
            }
            ENDCG
        }
    }
}