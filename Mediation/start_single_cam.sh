#!/bin/bash

turn_on_camera() {
	echo 'turn on camera $1'
   	cd ../Pylon/SingleCamera
   	pwd
   	echo "Running RegularGrab /dev/video$1 $2"
	nohup ./RegularGrab "/dev/video$1" "$2"  &>/dev/null &
}


if [ $1 == "start" ]; then
	echo "Make sure Grab_MultipleCameras is down and openalpr daemon is down also"
	systemctl stop openalpr-daemon
        ps -ef | grep 'Grab_MultipleCameras' | grep -v grep | awk '{print $2}' | xargs -r kill -9
	sleep 1
	echo "Turning on camera $2"
	turn_on_camera $2 $3
elif [ $1 == "stop" ]; then
	echo "Killing all RegularGrab processes"
	ps -ef | grep 'RegularGrab' | grep -v grep | awk '{print $2}' | xargs -r kill -9
else
	echo "Wrong Parameter"
fi

