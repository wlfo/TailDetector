# TailDetector

The **TailDetector** is an automotive system for surveillance detecting. 
It was developed as a Proof of the Concept of using a computer vision system to detect possible car surveillance. 

The system consists of three major components:
* Four [Cameras](#cameras) installed inside a vehicle (one front camera and three other on the back of the vehicle).
* A [Single Board Computer](#single-board-computer) with high GPU capabilities enabling complex AI operations for automated license plate recognition.
* An [Ios Application](#ios-application) to draw "detection routes", control the single-board computer and to get alerts in case of detected surveillance ("Tails").


## Cameras
I am using Basler dart cameras with USB 3.0 interface. According to Basler,USB 3.0 Vision interface offers a 350 MB/s bandwidth volume, which is suitable for this scenario. This interface also offers highly reliable data transfer between host and device and integrated (buffer) memory for top stability in industrial applications. Wiring inside a vehicle does not require more than 8m cable length (also supported by this interface). 

## Single Board Computer

## Ios Application


# General scheme of the system
<p align="center">
  <img src="readme/Scheme.png" width="800" title="hover text">
</p>



