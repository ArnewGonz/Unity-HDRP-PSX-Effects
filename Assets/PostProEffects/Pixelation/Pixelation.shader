Shader "PostPoEffect/Pixelation"
{
    Properties
    {
        _MainTex("Texture", 2DArray) = "white" {}
	    _WidthPixelation ("Width", float) = 1.0
	    _HeightPixelation ("Height", float) = 1.0
	    _ColorPrecision ("Color", float) = 1.0
    }

 HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO

    };

        
    TEXTURE2D_X(_MainTex);  
        
    //for Pixelation      
    float _WidthPixelation;
    float _HeightPixelation;
        
    //for color precision
    float _ColorPrecision;

    Varyings Vert(Attributes input)
    {
        Varyings output;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);

        return output;
    }

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        //pixelation 
        float2 uv = input.texcoord;
        uv.x = floor(uv.x * _WidthPixelation) / _WidthPixelation;
        uv.y = floor(uv.y * _HeightPixelation) / _HeightPixelation;
        
        float3 sourceColor = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, uv);

        //color precision
        float3 color = floor(sourceColor * _ColorPrecision) / _ColorPrecision;
        return float4(color, 1);
    }

    ENDHLSL
    
    SubShader
    {
        Pass
        {
            Name "xddddddd"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }

    Fallback Off
}
