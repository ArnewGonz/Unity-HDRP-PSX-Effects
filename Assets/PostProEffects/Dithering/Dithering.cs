using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

[Serializable, VolumeComponentMenu("Post-processing/Custom/Dithering")]
public sealed class Dithering : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public IntParameter PatternIndex = new IntParameter(0);
    public FloatParameter DitherThreshold = new FloatParameter(0f);
    public FloatParameter DitherScale = new FloatParameter(0f);

    Material m_Material;

    public bool IsActive() => m_Material != null && PatternIndex.value >= 0;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > Graphics > HDRP Global Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.BeforePostProcess;

    const string kShaderName = "PostPoEffect/Dithering";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume Dithering is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetInt("_PatternIndex", PatternIndex.value);
        m_Material.SetFloat("_DitherThreshold", DitherThreshold.value);
        m_Material.SetFloat("_DitherScale", DitherScale.value);
        cmd.Blit(source, destination, m_Material, 0);

        //Aprender diferencia entre Blit y esta funcion
        //HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 0);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}