Shader "My/Water Shader"
{
    Properties
    {
        
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            
            struct appdata
            {
                float4 vertex : POSITION;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            
            v2f vertex(appdata indata)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(indata.vertex);
                
                return o;
            }
            
            float4 fragment(v2f indata) : SV_TARGET
            {
                return float4(1, 0, 0, 1);
            }
            ENDCG
        }
    }
}