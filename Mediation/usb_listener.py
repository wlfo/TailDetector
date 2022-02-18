import json
import beanstalkc
import pyudev
import time
import socket

from pprint import pprint
from peertalk.PeerTalk import PeerTalk
from peertalk.PeerTalkVehicle import PeerTalkVehicle
from peertalk.PTGeneralWrapper import PTGeneralWrapper
from peertalk.TransmissionType import TransmissionType

from utils import Utils


def usbmuxd_active():
    result = False
    # Detect if device is USBMUXD
    for i in range(4):
        if "Active: active (running)" in Utils.cmdline("systemctl status usbmuxd.service").decode("utf-8"):
            print("usbmuxd is active")
            result = True
            break
        else:
            print("usbmuxd is not active")
            time.sleep(2)
    return result


def monitor_usb_device():
    # Detect USB Insert
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by(subsystem='usb')
    for device in iter(monitor.poll, None):
        print(device.action)
        if device.action == 'add':
            print('{} connected'.format(device))
            if usbmuxd_active():
                break
            # do something very interesting here.


def is_socket_closed(sock: socket.socket) -> bool:
    try:
        # this will try to read bytes without blocking and also without removing them from buffer (peek only)
        data = sock.recv(16, socket.MSG_DONTWAIT | socket.MSG_PEEK)
        if len(data) == 0:
            print("############################ Connection was Closed")
            return True
    except BlockingIOError:
        return False  # socket is open and reading from it would block
    except ConnectionResetError:
        return True  # socket was closed for some other reason
    except Exception as e:
        print("################################ unexpected exception when checking if a socket is closed")
        return False
    return False


def loop_over_plates(beans):
    # Loop forever
    while True:

        # Wait for a second to get a job. If there is a job, process it and delete it from the queue.
        # If not, return to sleep.
        job = beans.reserve(timeout=2.0)
        if is_socket_closed(pt_vehicle.p_sock):
            print("Socket Closed. breaking")
            break

        if job is None:
            print("No plates available right now, waiting...")
            continue
        else:
            gap = beanstalkc.stats_tube('alprd')['current-jobs-reserved']
            print(f'------------------ Gap is: {gap} ------------')
            print("Found a plate!")
            plates_info = json.loads(job.body)

            # Do something with this data (e.g., match a list, open a gate, etc.).
            if 'data_type' not in plates_info:
                print("This shouldn't be here... all OpenALPR data should have a data_type")
            elif plates_info['data_type'] == 'alpr_results':
                print("This is a plate result")
                pprint(plates_info)
                handle_info(plates_info)
            elif plates_info['data_type'] == 'alpr_group':
                #pprint(plates_info)
                print("This is a group result")
                detection_data = build_detection_data(plates_info)
                print(f'----------------- Best Plate Number: {detection_data["best_plate_number"]} ---------')
                print(f'----------------- Camera ID: {detection_data["camera_id"]} ---------')
                handle_info(detection_data)
            elif plates_info['data_type'] == 'heartbeat':
                print("This is a heartbeat")

            # Delete the job from the queue when it is processed.
            job.delete()


def build_detection_data(plates_info):
    vehicle = plates_info['vehicle']
    make_0 = vehicle['make'][0]['name']
    color_0 = vehicle['color'][0]['name']
    make_model_0 = vehicle['make_model'][0]['name']
    year_0 = vehicle['year'][0]['name']
    vehicle_crop_jpeg = plates_info['vehicle_crop_jpeg']

    data_set = {'plate': plates_info['best_plate']['plate'],
                'plate_crop_jpeg': plates_info['best_plate']['plate_crop_jpeg'],
                'best_plate_number': plates_info['best_plate_number'],
                'country': plates_info['country'],
                'camera_id': plates_info['camera_id'],
                'gps_latitude': plates_info['gps_latitude'],
                'gps_longitude': plates_info['gps_longitude'],
                'make': make_0,
                'color': color_0,
                'make_model': make_model_0,
                'year': year_0,
                'vehicle_crop_jpeg': vehicle_crop_jpeg}

    return data_set


def handle_info(plates_info):
    json_string = json.dumps(plates_info)
    r8 = json_string.encode("utf-8")
    pt_vehicle.send(r8, TransmissionType.MESSAGE.value, pt_vehicle.p_sock)


def keep_alive():
    r8 = "keep_alive".encode("utf-8")
    pt.send(r8, TransmissionType.MESSAGE.value, pt.p_sock)


def init_beanstalk():
    # Beanstalk
    beans = beanstalkc.Connection(host='localhost', port=11300)
    tube_name = 'alprd'

    # For diagnostics, print out a list of all the tubes available in Beanstalk.
    print(beans.tubes())

    # For diagnostics, print the number of items on the current alprd queue.
    try:
        pprint(beans.stats_tube(tube_name))
    except beanstalkc.CommandFailed:
        print("Tube doesn't exist")

    beans.watch(tube_name)

    # Empty old jobs from queue
    while True:
        job = beans.reserve(timeout=1.0)
        if job is None:
            break
        job.delete()

    # For diagnostics, print the number of items on the current alprd queue.
    try:
        pprint(beans.stats_tube(tube_name))
    except beanstalkc.CommandFailed:
        print("Tube still doesn't exist")

    print(beans.tubes())

    return beans


pt_connect = False
pt_vehicle_connect = False
pt = None
pt_vehicle = None

while True:
    # Check if ios device is connected
    if not usbmuxd_active():
        # Monitor USB device adding event
        monitor_usb_device()

    try:
        # PeerTalk
        time.sleep(2)

        # If device was disconnected again, pt should be None
        if pt is None:
            pt = PeerTalk(2345, 0, 20.0)
        elif is_socket_closed(pt.p_sock):
            # Socket maybe closed due to swift app down or first time run
            print("Socket Closed. Reset peertalk")
            pt_connect = False
            pt = None
            continue

        if pt_vehicle is None:
            pt_vehicle = PeerTalkVehicle(2347, 0, None) #2)
        elif is_socket_closed(pt_vehicle.p_sock):
            # Socket maybe closed due to swift app down or first time run
            pt_vehicle_connect = False
            pt_vehicle = None
            continue

        # Problem if closing swift app - connection already exist - when relaunch swift not recognize connection

        if pt_connect is False:
            print("Problem with connection. Check application on the other side!")
            time.sleep(1)
            pt_connect = pt.try_connect_abstract(PTGeneralWrapper)

        if pt_vehicle_connect is False:
            print("Problem with connection while trying to connect pt_vehicle.")
            time.sleep(1)
            pt_vehicle_connect = pt_vehicle.try_connect_abstract(PTGeneralWrapper)


        # Watch the "alprd" tube; this is where the plate data is.
        if pt_connect is True and pt_vehicle_connect is True:
            beanstalk = init_beanstalk()
            loop_over_plates(beanstalk)
    except BrokenPipeError:
        print("Broken Pipe")
    except Exception as e:
        pt_connect = False
        pt_vehicle_connect = False
        print(e)
