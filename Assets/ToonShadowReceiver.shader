Shader "Roystan/Toon Shadow Receiver"
{
	Properties
	{
		_Alpha("Alpha", Range(0, 1)) = 1
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
			Name "Toon Shadow Receiver"
			
			Blend SrcAlpha OneMinusSrcAlpha
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			struct Attributes
			{
				float4 vertex : POSITION;				
			};

			struct Varyings
			{
				float4 posCS : SV_POSITION;
				float3 posWS : TEXCOORD0;
				float4 shadowCoord : TEXCOORD1;
			};

			float _Alpha;
			
			Varyings vert (Attributes IN)
			{
				Varyings OUT;
				OUT.posCS = TransformObjectToHClip(IN.vertex.xyz);
				OUT.posWS = TransformObjectToWorld(IN.vertex.xyz);
				
				OUT.shadowCoord = TransformWorldToShadowCoord(OUT.posWS);
				
				return OUT;
			}
			
			half4 frag (Varyings IN) : SV_Target
			{
				float shadow = MainLightRealtimeShadow(IN.shadowCoord);
				return  half4(0, 0, 0, (1 - shadow) * _Alpha);
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