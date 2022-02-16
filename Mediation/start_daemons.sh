#!/bin/bash

turn_on_cameras() {
	echo 'turn on camertas'
   	cd ../Pylon/MultipleCameras
   	pwd
   	echo "Running Grab_MultipleCameras"
	nohup ./Grab_MultipleCameras  "$1" &>/dev/null &
}

if [ $1 == "start" ]; then
	echo "Make sure RegularGrab process is down"
	ps -ef | grep 'RegularGrab' | grep -v grep | awk '{print $2}' | xargs -r kill -9
	ps -ef | grep 'Grab_Multiple' | grep -v grep | awk '{print $2}' | xargs -r kill -9
        sleep 1
        echo "Setting Date"
        echo $a
        IFS=' '
        read -a strarr <<< "$3"
        echo ${strarr[0]}
        echo ${strarr[1]}

        date --set=${strarr[0]}
        date --set=${strarr[1]}
        hwclock --systohc
        sleep 1
        systemctl start openalpr-daemon
        turn_on_cameras $2
elif [ $1 == "stop" ]; then
	systemctl stop openalpr-daemon
	ps -ef | grep 'Grab_MultipleCameras' | grep -v grep | awk '{print $2}' | xargs -r kill -9
else
	echo "Wrong Parameter"
fi

