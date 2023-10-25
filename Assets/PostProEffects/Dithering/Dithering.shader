Shader "PostPoEffect/Dithering"
{
    Properties
    {
        _MainTex("Texture", 2DArray) = "white" {}
    }

 HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    TEXTURE2D_X(_MainTex);  
    float2 _MainTex_TexelSize;

    //for dither     
    uint _PatternIndex; 
    float _DitherThreshold;
    float _DitherScale;

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

    float4x4 GetDitherPattern(uint index)
    {
        float4x4 pattern;
    
        if(index == 0)
        {
            pattern = float4x4
            (
                0 , 1 , 0 , 1 ,
                1 , 0 , 1 , 0 ,
                0 , 1 , 0 , 1 ,
                1 , 0 , 1 , 0 
            );
        }         
        else if(index == 1)
        {
            pattern = float4x4
            (
                0.23 , 0.2 , 0.6 , 0.2 ,
                0.2 , 0.43 , 0.2 , 0.77,
                0.88 , 0.2 , 0.87 , 0.2 ,
                0.2 , 0.46 , 0.2 , 0 
            );
        }           
        else if(index == 2)
        {
            pattern = float4x4
            (
                 -4.0, 0.0, -3.0, 1.0,
                 2.0, -2.0, 3.0, -1.0,
                 -3.0, 1.0, -4.0, 0.0,
                 3.0, -1.0, 2.0, -2.0
            );
        }       
        else if(index == 3)
        {
            pattern = float4x4
            (
                1 , 0 , 0 , 1 ,
                0 , 1 , 1 , 0 ,
                0 , 1 , 1 , 0 ,
                1 , 0 , 0 , 1 
            );
        }          
        else 
        {
            pattern = float4x4
            (
                1 , 1 , 1 , 1 ,
                1 , 1 , 1 , 1 ,
                1 , 1 , 1 , 1 ,
                1 , 1 , 1 , 1 
            );
        }
        
        return pattern;
    }
    
    float PixelBrightness(float3 col)
    {
        return col.r + col.g + col.b / 3.0;
    }
    
    float4 GetTexelSize(float width, float height)
    {
        return float4(1/width, 1/height, width, height);
    }
    
    float Get4x4TexValue(float2 uv, float brightness, float4x4 pattern)
    {        
        uint x = uv.x % 4;
        uint y = uv.y % 4;
        
        if((brightness * _DitherThreshold) < pattern[x][y]) 
            return 0;
        else 
            return 1;
    }
        
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

        //base texture 
        float4 Color = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, input.texcoord);
        
        //dithering  
        float4 texelSize = GetTexelSize(1,1);
        float2 screenPos = input.texcoord.xy;
        uint2 ditherCoordinate = screenPos * _ScreenParams.xy * texelSize.xy;

        ditherCoordinate /= _DitherScale;
        
        float brightness = PixelBrightness(Color.rgb);
        float4x4 ditherPattern = GetDitherPattern(_PatternIndex);
        float ditherPixel = Get4x4TexValue(ditherCoordinate.xy, brightness, ditherPattern);
        
        return Color * ditherPixel;   
    }

    ENDHLSL
    
    SubShader
    {
        Pass
        {
            Name "Dithering"

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
