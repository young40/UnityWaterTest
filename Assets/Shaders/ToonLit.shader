Shader "Roystan/Toon/Lit"
{
    Properties
    {
        [HDR]
		_Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
		{ 
		    "RenderPipeLine" = "UniversalPipeLine"
			"RenderType" = "Opaque"
		}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPreMaterial)
                float4 _MainTex_ST;
                float4 _Color;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {
                float3 normalWS = normalize(IN.normalWS);
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                
                Light mainLight = GetMainLight();
                float NdotL = dot(normalWS, mainLight.direction);
                
                float lightIntensity = saturate(floor(NdotL * 3.0) / 1.5);
                
                color.rgb *= lightIntensity * mainLight.color;
                color.rgb *= SampleSH(normalWS);
                
                return color;
            }
            ENDHLSL
        }
    }
}
