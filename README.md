# Unity HDRP PSX Effects
A collection of PSX effects optimized for the HD Render Pipeline (HDRP). The aim of this project was to be able to blend the Playstation 1 era graphics and effects with the more cutting-edge techniques included in the HDRP.
This collection of effects include:
- PRB shadergraph for Vertex snapping/Jittering.
- Screen-space pixelation and color adjustment effect.
- Screen-space dithering.

### Demo
The project includes a Demo scene (Demo) to test the effects.

<p align="center">
  <img src="Media/gif01.gif" width=75%>
</p>

### Adding the Pixelation and Dithering effects
To be able to use the Pixelation and Dithering effects in a Volume you must add them to the Custom Post-Process Order list:

<p align="center">
  <img src="Media/InjectionPoint.png" width=75%>
</p>

If you want to change the injection point, go the Pixelation.css and Dithering.css (change one or both, they are independent) and set **injectionPoint** to any other CustomPostProcessInjectionPoint option from the lists shown in the image. After this change, don't forget to change it at the Custom Post-Process Order list.

### Building the project with the effects
In order to build the project and see the effects, you must add the shaders to the **Always Included Shaders** list:

<p align="center">
  <img src="Media/AddToBuild.png" width=75%>
</p>

### References
- Retro house pack: https://elegantcrow.itch.io/retro-house-pack
- European small family car (1960s and 1970s): https://ggbot.itch.io/psx-style-car
- Pine trees and rocks: https://nartier.itch.io/ps1-style-nature-assets
- Kodrin's URP-PSX, from which Dithering and Pixelation are mostly port to HDRP and a great source of information for the Jitter Shader: https://github.com/Kodrin/URP-PSX

### License
CC0! Feel free to use it in your projects, I'll be very happy if you show me your results! 
