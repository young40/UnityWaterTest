Shader "ShaderTest"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Sub1Tex ("Sub1 Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline" }
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
                float2 uv1: TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_Sub1Tex);
            SAMPLER(sampler_Sub1Tex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _Sub1Tex_ST;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _Sub1Tex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col;

                if (i.uv.x > 0.5)
                {
                    col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv); //tex2D(_MainTex, i.uv);
                }
                else
                {
                    col = SAMPLE_TEXTURE2D(_Sub1Tex, sampler_Sub1Tex, i.uv1); //tex2D(_MainTex, i.uv);
                }
                return col;
            }
            ENDHLSL
        }
    }
}
