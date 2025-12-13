Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
		
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness("Glossiness", Float) = 32
		
		[HDR]
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
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
			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			
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
				float3 viewDir : TEXCOORD1;
				float4 shadowCoord : TEXCOORD3;
			};

			TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float4 _Color;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Glossiness;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
			
			Varyings vert (Attributes IN)
			{
				Varyings OUT;
				OUT.pos = TransformObjectToHClip(IN.vertex);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				
				VertexPositionInputs vertexInput =GetVertexPositionInputs(IN.vertex); 
				
				OUT.viewDir = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
				
				OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);
				
				OUT.shadowCoord = GetShadowCoord(vertexInput);
				
				return OUT;
			}
			
			float4 frag (Varyings IN) : SV_Target
			{
				Light mainLight = GetMainLight(IN.shadowCoord);
				
				float shadow = MainLightRealtimeShadow(IN.shadowCoord);
				
				float3 normal = normalize(IN.worldNormal);
				float NDotL = dot(mainLight.direction, normal);
				
				float lightIntensity = smoothstep(0, 0.01, NDotL * shadow);
				//lightIntensity = step(0, NDotL);
				
				float3 viewDir = IN.viewDir;// normalize(IN.viewDir);
				float3 halfVector = normalize(mainLight.direction + viewDir);
				float NdotH = dot(normal, halfVector);
				
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float spceularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = spceularIntensitySmooth * _SpecularColor;
				
				float4 rimDot = 1 - dot(viewDir, normal);
				float rimIntensity = rimDot * pow(NDotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;
				
				float4 light = float4(lightIntensity * mainLight.color, 1);
				
                float4 sample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

				return (light + _AmbientColor + specular + rim) * _Color * sample;
			}
			ENDHLSL
		}

		Pass
		{
			Name "My Toon ShadowCaster"
			Tags { "LightMode" = "ShadowCaster"}
			
			ZWrite On
			ZTest LEqual
			ColorMask 0
			
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ _SHADOWS_SOFT	
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			struct  Attributes
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct Varyings
			{
				float4 pos : SV_POSITION;	
			};
			
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				
				float4 position = TransformObjectToHClip(IN.vertex.xyz);
				#if UNITY_REVERSED_Z
				position.z = min(position.z, position.w * UNITY_NEAR_CLIP_VALUE);
				#else
				position.z = max(position.z, position.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				
				OUT.pos = position;
				 
				return OUT;	
			}
			
			half4 frag(Varyings IN) : SV_TARGET
			{
				return 0;
			}
			
			ENDHLSL
		}
	}
}