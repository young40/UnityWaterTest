Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
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
				float4 vertex : POSITION;				
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Varyings
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				float4 shadowCoord : TEXCOORD3;
			};

			TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float4 _Color;
			float4 _AmbientColor;
			
			Varyings vert (Attributes IN)
			{
				Varyings OUT;
				OUT.pos = TransformObjectToHClip(IN.vertex);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);
				
				OUT.shadowCoord = GetShadowCoord(GetVertexPositionInputs(IN.vertex));
				
				return OUT;
			}
			
			float4 frag (Varyings IN) : SV_Target
			{
				Light mainLight = GetMainLight(IN.shadowCoord);
				
				float3 normal = normalize(IN.worldNormal);
				float NDotL = dot(_MainLightPosition.xyz, normal);
				
				float lightIntensity = step(0, NDotL);
				
				float4 light = float4(lightIntensity * mainLight.color, 1);
				
                float4 sample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

				return (light + _AmbientColor) * _Color * sample;
			}
			ENDHLSL
		}
	}
}