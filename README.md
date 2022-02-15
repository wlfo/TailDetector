# TailDetector

The **TailDetector** is an automotive system for surveillance detecting. 
It was developed as a Proof of the Concept of using a computer vision system to detect possible car surveillance. 

The system consists of three major components:
* Four [Cameras](#cameras) installed inside a vehicle (one front camera and three other on the back of the vehicle).
* A [Single Board Computer](#single-board-computer) with high GPU capabilities enabling complex AI operations for automated license plate recognition.
* An [Ios Application](#ios-application) to draw "detection routes", control the single-board computer and to get alerts in case of detected surveillance ("Tails").


## Cameras
I am using Basler dart cameras with USB 3.0 interface. [According to Basler](https://www.baslerweb.com/en/vision-campus/interfaces-and-standards/usb3-interface-future/), USB 3.0 Vision interface offers a 350 MB/s bandwidth volume, which is suitable for this scenario. This interface also offers highly reliable data transfer between host and device and integrated (buffer) memory for top stability in industrial applications. Wiring inside a vehicle does not require more than 8m cable length (also supported by this interface). 

## Single Board Computer
Nvidia produces very popular developer kits suitable for missions like this. I am using Jetson Xavier NX Developer Kit. Xavier NX has very impressive GPU features: 384 CUDA cores + 48 Tensor cores Volta GPU, 21 TOPS. There are 4 USB 3.0 ports on board. For more details See [Jetson Xavier NX Developer Kit](https://developer.nvidia.com/embedded/jetson-xavier-nx-devkit).

This single-board computer is actually the core of the system. Within this component the following functionality is managed:
* Transfering the streamed video into a "number plate recognition" service via Gstreamer pipelines.
* Automation of number plate recognition functionality using [Rekor Scout OpenALPR agent](https://www.openalpr.com/software/scout) (daemon). 
* Mediation layer (python process) for orchestration and mediation between all subsystems on the sbc: cameras functionality, daemons, two-way communication with ios applicarion via [peertalk protocol implementaion](https://github.com/rsms/peertalk) etc.
* Multiplexing connections over USB to the iOS device using [USBMUXD](https://github.com/libimobiledevice/usbmuxd) daemon. 


## Ios Application
In order to command and control the core system

# General scheme of the system
<p align="center">
  <img src="readme/Scheme.png" width="800" title="hover text">
</p>



