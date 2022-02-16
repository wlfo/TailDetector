#include <stdio.h>
#include <stdlib.h>
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
#include <map>

#include <pylon/PylonIncludes.h>

using namespace Pylon;
using namespace std;

// Number of images to be grabbed.
static const size_t c_maxCamerasToUse = 4;

static int width = 1280; //3840;
static int height = 720; //720; //2160;
static unsigned char *vidsendbuf = NULL;
static const int vidsendsize = width * height * 3;
static int numberOfPipes = 0;

static int open_vpipe(char *v4l2dev) {
	int v4l2sink = -1;
	v4l2sink = open(v4l2dev, O_WRONLY);
	if (v4l2sink < 0) {
		fprintf(stderr, "Failed to open v4l2sink device. (%s)\n",
				strerror(errno));
		exit(-2);
	}
	// setup video for proper format
	struct v4l2_format v;
	memset(&v, 0, sizeof(v));
	int t;
	v.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
	t = ioctl(v4l2sink, VIDIOC_G_FMT, &v);
	if (t < 0)
		exit(t);
	v.fmt.pix.width = width;
	v.fmt.pix.height = height;
	v.fmt.pix.pixelformat = V4L2_PIX_FMT_RGB24;
	v.fmt.pix.sizeimage = vidsendsize;
	v.fmt.pix.field = V4L2_FIELD_NONE;
	t = ioctl(v4l2sink, VIDIOC_S_FMT, &v);
	if (t < 0)
		exit(t);

	return v4l2sink;

}


std::map<std::string, int> parse (char str[])
{
    map<string, int> mymap;
    char *token;

    token = strtok(str, ",");
    while (token != NULL) {
        string s(token);
        size_t pos = s.find(":");
        mymap[s.substr(0, pos)] = atoi(s.substr(pos + 1, string::npos).c_str());
        token = strtok(NULL, ",");
    }

    for (auto keyval : mymap)
        cout << keyval.first << ":" << keyval.second << endl;

    return mymap;
}


int main(int argc, char *argv[]) {
	// The exit code of the sample application.
	int exitCode = 0;

	if (argc !=2 ){
		cout << "Missing Argument: ./Grab_MultipleCameras camera1serialnumber:videoIdx1,camera2serialnumber:videoIdx2" << endl;
		return 0;
	}


	// Parse argv to map of <camera serial number, video index>
	std::map<std::string, int> camerasMap = parse(argv[1]);

	// Before using any pylon methods, the pylon runtime must be initialized.
	PylonInitialize();
	int *v4l2sink;


	try {
		// Get the transport layer factory.
		CTlFactory &tlFactory = CTlFactory::GetInstance();

		// Get all attached devices and exit application if no device is found.
		DeviceInfoList_t devices;
		if (tlFactory.EnumerateDevices(devices) == 0) {
			throw RUNTIME_EXCEPTION( "No camera present.");
		}

		// Create an array of instant cameras for the found devices and avoid exceeding a maximum number of devices.
		CInstantCameraArray cameras(min(devices.size(), c_maxCamerasToUse));

		// Todo: complete
		// Size of cameras to create array of v4l2sink

		numberOfPipes = cameras.GetSize();
		v4l2sink = new int[numberOfPipes]{-1};

		// Create and attach all Pylon Devices.
		for (size_t i = 0; i < cameras.GetSize(); ++i) {
			cameras[i].Attach(tlFactory.CreateDevice(devices[i]));

			// Print the model name of the camera.
			cout << "Using device " << cameras[i].GetDeviceInfo().GetModelName()
					<< endl;

			///////////////////////////

			GenApi::INodeMap &nodemap = cameras[i].GetNodeMap();

			cameras[i].Open();

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
			std::cout << "Sensor Width: " << _sensorWidth->GetValue(false, true)
					<< endl;
			GenApi::CIntegerPtr _sensorHeight = nodemap.GetNode("SensorHeight");
			std::cout << "Sensor Height: "
					<< _sensorHeight->GetValue(false, true) << endl;

			int ox = (_sensorWidth->GetValue(false, true) - width) / 2;
			int oy = ((_sensorHeight->GetValue(false, true) - height) / 2) & ~1;

			cout << "ox = " << ox << " oy = " << oy << endl;

			_offsetX->SetValue(ox);
			_offsetY->SetValue(oy);

			// Disable Mirroring
			if (cameras[i].GetDeviceInfo().GetModelName() == "daA3840-45uc") {
				// Enable Reverse X
				CBooleanParameter(nodemap, "ReverseX").SetValue(true);
				// Enable Reverse Y, if available, if daA3840-45uc
				CBooleanParameter(nodemap, "ReverseY").SetValue(true);
			}

			cameras[i].MaxNumBuffer = 10;

			///////////////////////////


			// Map camera to video device according serial number
			std::map<std::string, int>::iterator it;
			it = camerasMap.find(cameras[i].GetDeviceInfo().GetSerialNumber().c_str());

			if (it == camerasMap.end()){
				v4l2sink[i] = -1;
				cout << "No Video Device For " << cameras[i].GetDeviceInfo().GetSerialNumber() << endl;
				continue;
			}

			int videoNum = camerasMap[cameras[i].GetDeviceInfo().GetSerialNumber().c_str()];

			cout << "VideoNum for device: " << cameras[i].GetDeviceInfo().GetSerialNumber() << " is: " << videoNum << endl;
			char v4l2dev[32];
			sprintf(v4l2dev, "/dev/video%d", videoNum);

			v4l2sink[i] = open_vpipe(v4l2dev);
		}

		CImageFormatConverter formatConverter;
		formatConverter.OutputPixelFormat = PixelType_RGB8packed;
		CPylonImage pylonImage;
		int grabbedlmages = 0;
		vidsendbuf = (unsigned char*) malloc(vidsendsize);


		// Starts grabbing for all cameras starting with index 0. The grabbing
		// is started for one camera after the other. That's why the images of all
		// cameras are not taken at the same time.
		// However, a hardware trigger setup can be used to cause all cameras to grab images synchronously.
		// According to their default configuration, the cameras are
		// set up for free-running continuous acquisition.
		cameras.StartGrabbing(GrabStrategy_LatestImages);

		// This smart pointer will receive the grab result data.
		CGrabResultPtr ptrGrabResult;

		// Grab c_countOfImagesToGrab from the cameras.
		while (cameras.IsGrabbing())
		{

			cameras.RetrieveResult(5000, ptrGrabResult,
					TimeoutHandling_ThrowException);

			// Image grabbed successfully?
			if (ptrGrabResult->GrabSucceeded()) {
				// When the cameras in the array are created the camera context value
				// is set to the index of the camera in the array.
				// The camera context is a user settable value.
				// This value is attached to each grab result and can be used
				// to determine the camera that produced the grab result.
				intptr_t cameraContextValue = ptrGrabResult->GetCameraContext();

				if (v4l2sink[cameraContextValue] == -1) {
					cout << "Camera without Video Device\n\n\n\n" << endl;
					continue;
				}

				// Print the index and the model name of the camera.
				cout << "Camera " << cameraContextValue << ": "
						<< cameras[cameraContextValue].GetDeviceInfo().GetModelName()
						<< endl;

				// Now, the image data can be processed.
				cout << "GrabSucceeded: " << ptrGrabResult->GrabSucceeded()
						<< endl;
				cout << "SizeX: " << ptrGrabResult->GetWidth() << endl;
				cout << "SizeY: " << ptrGrabResult->GetHeight() << endl;

				/////////////////////////////////////

				formatConverter.Convert(pylonImage, ptrGrabResult);

				// Todo: take with camera index, the right v4l2sink
				// If you need to record video
				size_t written = write(v4l2sink[cameraContextValue], pylonImage.GetBuffer(), vidsendsize);

				if (written < 0) {
					std::cerr << "ERROR: could not write to output device!\n";
					close (v4l2sink[cameraContextValue]);
					break;
				} else {
					cout << "Written: " << written << endl;
				}



				///////////////////////////////////


				const uint8_t *pImageBuffer = (uint8_t*) ptrGrabResult->GetBuffer();
				cout << "Gray value of first pixel: "
						<< (uint32_t) pImageBuffer[0] << endl << endl;
			} else {
				cout << "Error: " << std::hex << ptrGrabResult->GetErrorCode()
						<< std::dec << " "
						<< ptrGrabResult->GetErrorDescription() << endl;
			}
		}
	} catch (const GenericException &e) {
		// Error handling
		cerr << "An exception occurred." << endl << e.GetDescription() << endl;
		exitCode = 1;
	}

	// Comment the following two lines to disable waiting on exit.
	cerr << endl << "Press enter to exit." << endl;
	while (cin.get() != '\n')
		;

	// Releases all pylon resources.
	PylonTerminate();

	for (int i=0;i<numberOfPipes;i++){
		if (v4l2sink[i] != 0){
			close(v4l2sink[i]);
		}
	}

	delete[] v4l2sink;


	return exitCode;
}
