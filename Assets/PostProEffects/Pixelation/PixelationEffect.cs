using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

[Serializable, VolumeComponentMenu("Post-processing/Custom/PixelationEffect")]
public sealed class PixelationEffect : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public FloatParameter Width = new FloatParameter(0f);
    public FloatParameter Height = new FloatParameter(0f);
    public FloatParameter Color = new FloatParameter(0f);

    Material m_Material;

    public bool IsActive() => m_Material != null && Width.value > 0f && Height.value > 0f && Color.value > 0f;

    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.BeforePostProcess;

    const string kShaderName = "PostPoEffect/Pixelation";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume CRTEffect is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_WidthPixelation", Width.value);
        m_Material.SetFloat("_HeightPixelation", Height.value);
        m_Material.SetFloat("_ColorPrecision", Color.value);
        cmd.Blit(source, destination, m_Material, 0);

        //Aprender diferencia entre Blit y esta funcion
        //HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 0);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
