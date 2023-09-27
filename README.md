# Barcoder_Simulator
## Overview

 "Barcoder_Simulatar" can simulate the sound of the "Barcoder" by scanning the drawn diagram.

 "Barcoder" is an instrument modified from a barcode reader.

![操作画面](<img/BarcodeSimlator.png>)


## Requirement
* Processing
* Minim library

## Usage
### Basic Operations
* Use the mouse to control the red laser line.

* Left-click the mouse to produce a sound.  
The sound is a result of converting the red component of the shapes below the laser line into a sound waveform.

### Options
* Scroll Wheel  
Adjusting the Length of the Laser Line.  
When variable volume is enabled, the volume decreases when the laser line is longer or when the barcode is further away.

* Key 'V'  
Enable or Disable Variable Volume.

* Key'1'-'9'  
Coefficient for Linear Interpolation(Lerp),, allowing you to adjust the smoothness of the waveform.  
A value of 1 corresponds to 0.1, while 9 corresponds to 0.9. Smaller values result in a smoother transition.

* Key '←' or '→'  
Toggle the waveform mirroring Enable or Disable.  
It is typically enabled to replicate laser swings.

* Key 'Space'  
Set whether to apply a window function to the waveform or not.  
Window functions are typically enabled to replicate the weakening of light at the edges of swings on both sides.

* Key '↑' or '↓'
Adjust the laser's width.  
A narrower width makes it easier to reproduce high-frequency components.

* Key 'D'  
Change the shape to be scanned.  
By modifying the program code, you can scan any desired shape.

## Note
* The green waveform at the bottom represents the red color intensity waveform of the red laser line, while the pink waveform represents the post-processing waveform. The post-processed waveform is being output as audio.

## License
* MIT  