/*
 * RegularGrab.cpp
 *
 *  Created on: 4 Apr 2021
 *      Author: root
 */


#include <linux/videodev2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>                /* low-level i/o */
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <malloc.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <linux/videodev2.h>
#include <iostream>
#include <string>

// Load PYLON API.
#include <pylon/PylonIncludes.h>

#include<iostream>

using namespace Pylon;
using namespace std;


// Camera dim: 3860x2178

static char *v4l2dev = "/dev/video0";
static char *serialNumber;
static int v4l2sink = -1;
static int width = 1280; //3840;
static int height = 720; //2160;
static unsigned char *vidsendbuf = NULL;
static int vidsendsize = 0;


static void open_vpipe()
{
	v4l2sink = open(v4l2dev, O_WRONLY);
	if (v4l2sink < 0) {
		fprintf(stderr, "Failed to open v4l2sink device. (%s)\n", strerror(errno));
		exit(-2);
	}
	// setup video for proper format
	struct v4l2_format v;
	memset(&v, 0, sizeof(v));
	int t;
	v.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
	t = ioctl(v4l2sink, VIDIOC_G_FMT, &v);
	if( t < 0 )
		exit(t);
	v.fmt.pix.width = width;
	v.fmt.pix.height = height;
	v.fmt.pix.pixelformat = V4L2_PIX_FMT_RGB24;
	vidsendsize = width * height * 3;
	v.fmt.pix.sizeimage = vidsendsize;
	v.fmt.pix.field = V4L2_FIELD_NONE;
	t = ioctl(v4l2sink, VIDIOC_S_FMT, &v);
	if( t < 0 )
		exit(t);
	vidsendbuf = (unsigned char*)malloc(vidsendsize);
}


int main(int argc, char *argv[])
{

	int deviceIdx = -1;
	if (argc !=3 ){
		cout << "Missing Argument: ./RegularGrab /dev/videoX serial_number" << endl;
		return 0;
	} else {
		v4l2dev = argv[1];
		serialNumber = argv[2];
		char c = v4l2dev[strlen(argv[1]) - 1];
		if (isdigit(c)){
			deviceIdx = c - 48;
			cout << "Video Device Number is: " << c << endl;
		} else {
			cout << "Wrong Argument: /dev/videoX - X must be digit" << endl;
			return 0;
		}
	}

	open_vpipe();

	PylonInitialize();
	//Pylon::PylonAutoInitTerm autoInitTerm;
	try
	{

		CTlFactory& TlFactory = CTlFactory::GetInstance();
		DeviceInfoList_t lstDevices;
		TlFactory.EnumerateDevices( lstDevices );
		if ( ! lstDevices.empty() ) {
			DeviceInfoList_t::const_iterator it;
			cout << "Number of Cameras connected: " << lstDevices.size() << endl;
			for ( it = lstDevices.begin(); it != lstDevices.end(); ++it )
				cout << it->GetFullName() << endl;
				cout << "_______________________" << endl;
		}
		else {
			cerr << "No devices found!" << endl;
		}



		CTlFactory& tlFactory = CTlFactory::GetInstance();
		CDeviceInfo deviceInfo;
		deviceInfo.SetSerialNumber(String_t(serialNumber));
		Pylon::EDeviceAccessiblityInfo isAccessableInfo;
		if (!tlFactory.IsDeviceAccessible(deviceInfo, Control, &isAccessableInfo)){
			cout << "Not Accessible" << endl;
			close(v4l2sink);

			return 0;
		}

		IPylonDevice* device = tlFactory.CreateDevice(deviceInfo);
		CInstantCamera camera( device  );

		//std::cout << "Using device " << camera.GetDeviceInfo().GetModelName() << endl;
		GenApi::INodeMap& nodemap = camera.GetNodeMap();

		camera.Open();

		GenApi::CStringPtr _dsn = nodemap.GetNode("DeviceSerialNumber");
		std::cout << _dsn->GetValue(false, true) << endl;

		// Setting Resolution
		GenApi::CIntegerPtr _width = nodemap.GetNode("Width");
		GenApi::CIntegerPtr _height = nodemap.GetNode("Height");
		_width->SetValue(width);
		_height->SetValue(height);

		// Setting offset of X and Y
		GenApi::CIntegerPtr _offsetX = nodemap.GetNode("OffsetX");
		GenApi::CIntegerPtr _offsetY = nodemap.GetNode("OffsetY");

		// Using Sensor width to calculate the right offset needed
		GenApi::CIntegerPtr _sensorWidth = nodemap.GetNode("SensorWidth");
		std::cout << "Sensor Width: " << _sensorWidth->GetValue(false, true) << endl;
		GenApi::CIntegerPtr _sensorHeight = nodemap.GetNode("SensorHeight");
		std::cout << "Sensor Height: " << _sensorHeight->GetValue(false, true) << endl;

		int ox = (_sensorWidth->GetValue(false, true) - width) / 2;
		int oy = ((_sensorHeight->GetValue(false, true) - height) / 2) & ~1;

		cout << "ox = " << ox << " oy = " << oy << endl;

		_offsetX->SetValue(ox);
		_offsetY->SetValue(oy);

		// Disable Mirroring
		String_t cameraModelName = camera.GetDeviceInfo().GetModelName();
		if (cameraModelName == "daA3840-45uc" || cameraModelName == "puA1280-54uc"){
			// Enable Reverse X
			CBooleanParameter(nodemap, "ReverseX").SetValue(true);
			// Enable Reverse Y, if available, if daA3840-45uc
			CBooleanParameter(nodemap, "ReverseY").SetValue(true);
		}


		camera.MaxNumBuffer = 54;//10;
		CImageFormatConverter formatConverter;
		formatConverter.OutputPixelFormat = PixelType_RGB8packed;
		CPylonImage pylonImage;
		int grabbedlmages = 0;

		// Pylon
		camera.StartGrabbing(GrabStrategy_LatestImages); //GrabStrategy_LatestImages
		CGrabResultPtr ptrGrabResult;

		while (camera.IsGrabbing())

		{
			camera.RetrieveResult(5000, ptrGrabResult, TimeoutHandling_ThrowException);
			if (ptrGrabResult->GrabSucceeded())
			{
				cout <<"SizeX: "<<ptrGrabResult->GetWidth()<<endl;
				cout <<"SizeY: "<<ptrGrabResult->GetHeight()<<endl;
				formatConverter.Convert(pylonImage, ptrGrabResult);

				// If you need to record video
				size_t written = write(v4l2sink, pylonImage.GetBuffer(), vidsendsize);

				if (written < 0) {
					std::cerr << "ERROR: could not write to output device!\n";
					close(v4l2sink);
					break;
				} else {
					cout << "Written: " << written << endl;
				}
			}
		}
	}
	catch (GenICam::GenericException &e)
	{
		// Error handling.
		cerr << "An exception occurred." << endl
				<< e.GetDescription() << endl;
	}

	PylonTerminate();
	close(v4l2sink);
	return 0;
}




