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
* Mediation layer (python process) for orchestration and mediation between all subsystems on the sbc: cameras functionality, daemons, two-way communication with ios applicarion via [peertalk protocol implementaion](#peertalk-protocol-implementation) etc.
* Multiplexing connections over USB to the iOS device using [USBMUXD](https://github.com/libimobiledevice/usbmuxd) daemon. 


## Ios Application
The ios application has capabilities such as: drawing a detection route, starting a surveillance detection phase and finally getting corresponding alerts.
Here, too, the two-way communication iOS-Linux is done by USBMUXD. Although wireless interfaces (e.g WiFi) for maintaining this communication could be much simpler and intuitive, I chose to implement the entire iPhone-Jetson communication using peertalk over USB connection (i.e "closed system"). This choice can be considered as one more step toward reducing possible attack surface. In this decision exist at least one downside: the ios device must be connected to the jetson during all the detection phase.

# General scheme of the system
<p align="center">
  <img src="readme/Scheme.png" width="800" title="hover text">
</p>

## Peertalk Protocol Implementation
Seeking for secured wired communication between the iOS application and the core of the system (the Jetson Xavier), I encountered a pretty simple solution: USBMUXD and peertalk.

For the core system (Jetson) I extended the usbmux python script of [Hector Martin "marcan"](https://code.google.com/archive/p/iphone-dataprotection/source/default/source) to support three different channels of communication between two devices (iOS device and Linux device):
* Command - The iOS Application sends control messages directed to the Mediation subsystem on the Jetson device. The Mediation subsystem sends an appropriate response.
* Video - The iOS Application receives a stream of video frames from a selected single camera using the Mediation subsystem as a mediator. This feature enables camera preview prior the detection phase. 
* Vehicle - All vehicle recognition data produced by the OpenALPR agent encapsulated using the Mediation subsystem and being sent to the iOS application for further processing. 

[David House](https://github.com/davidahouse/peertalk-python) script example was very helpful in demonstrating how to create a communication channel using marcan's usbmux implementation. 
Finally, in order to implement these three channels in swift (on iOS device) I am using [Rasmus](https://github.com/rsms/peertalk) implementation of Cocoa library for communicating over USB. I also extended his PTChannelDelegate to support the three peertalk channels mentioned. 

# Installation Guide

## Pylon Camera Software Suite
Working with [Basler cameras](https://www.baslerweb.com/en/embedded-vision/embedded-vision-portfolio/embedded-vision-cameras/) require using pylon software. In this project I created two utilities using pylon c++ API. Pylon also support python (pypylon), but I have found it more convenient to use their c++ API. 
These two utilities are responsible for frame grabbing: [RegularGrab](Pylon/SingleCamera/RegularGrab.cpp) grabs frames from a given camera (using camera serial number as an argument), manipulate the grabbed frames and finally writes frames into v4l2 loop device (/dev/video device); 
[Grab_MultipleCameras](Pylon/MultipleCameras/Grab_MultipleCameras.cpp) get a list of pairs (camera's serial number, video loop device). It grabs frames from all cameras and writes frames to the corresponding video loop device.  
Software suite for Linux x86 (64 Bit) can be found here: [pylon 6.3.0 Camera Software Suite](https://www.baslerweb.com/en/sales-support/downloads/software-downloads/software-pylon-6-3-0-linux-x86-64bit/). Pylon's default installation folder is `/opt/pylon`. Along C/C++ code samples, Pylon provides very useful utility for cameras viewing, capturing and configuring: `/etc/pylon/bin/pylonviewer`.  

## V4l2loopback
In order to stream all grabbed frames from cameras to the OpenALPR daemon (via GStreamer pipeline as the daemon's requirement), we need to use v4l2 loopback devices.
Installation instruction can be found here [v4l2loopback](https://github.com/umlaeute/v4l2loopback).
In case of four cameras I am submitting this simple line after installation is finished.

    # modprobe v4l2loopback devices=4

Check that four devices have been created
~~~    
crw-rw----+ 1 root video 81, 0 Feb 17 11:50 /dev/video0
crw-rw----+ 1 root video 81, 1 Feb 17 11:50 /dev/video1
crw-rw----+ 1 root video 81, 2 Feb 17 11:50 /dev/video2
crw-rw----+ 1 root video 81, 3 Feb 17 11:50 /dev/video3
~~~~

## USBMUXD
See [libimobiledevice](https://libimobiledevice.org/), a cross-platform library to communicate with iOS devices natively.
Plug your iOS device and perform a simple check to ensure installation:
~~~
# ideviceinfo -k ProductVersion
15.3.1
~~~~
