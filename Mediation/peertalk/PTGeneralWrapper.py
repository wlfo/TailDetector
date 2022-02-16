import threading
import os
import subprocess
import time
from cameras import get_cameras
from peertalk.TransmissionType import TransmissionType
from utils import Utils
from peertalk.PeerTalkVideo import PeerTalkVideo
from peertalk.PeerTalkThreadBase import PeerTalkThreadBase


class PTGeneralWrapper(PeerTalkThreadBase):

    pt_video = None

    def __init__(self, *args):
        self.p_sock = args[0]
        self.send_func = args[1]
        self._running = True
        threading.Thread.__init__(self)

    def handle_generic_command(self, command):
        print("command: %s" % command)
        if command == "is_daemon_up":
            is_up = False
            if "Active: active (running)" in Utils.cmdline("systemctl status openalpr-daemon").decode("utf-8"):
                print("openalpr is active")
                is_up = True
            else:
                print("openalpr is not active")

            json_result = self.generate_response(command, '{{ \\\"is_up\\\" : {status} }}'.format(status=is_up))
            print(json_result)
            r8 = json_result.encode("utf-8")
            self.send_func(r8, TransmissionType.COMMAND.value, self.p_sock)
        elif command == "get_cameras_details":
            json_result = self.generate_response(command, '{{ \\\"cameras\\\" : {devices} }}'.format(devices=get_cameras()))
            print(json_result)
            r8 = json_result.encode("utf-8")
            self.send_func(r8, TransmissionType.COMMAND.value, self.p_sock)
        elif command[:len("start_daemon")] == "start_daemon":
            splitted_command = command.split()
            set_date_parameter = splitted_command[2].replace('_', ' ')
            if len(splitted_command) == 3:
                subprocess.call(['sudo', './start_daemons.sh', f'start', f'{splitted_command[1]}', f'{set_date_parameter}'])
        elif command == "stop_daemon":
            subprocess.call(['sudo', './start_daemons.sh', f'stop'])
        elif command[:len("start_video")] == "start_video":
            splitted_command = command.split()
            if len(splitted_command) > 2:
                self.start_video(splitted_command[1], splitted_command[2])
        elif command == "stop_video":
            self.stop_video()

    def stop_video(self):
        try:
            subprocess.call(['sudo', './start_single_cam.sh', f'stop'])
            time.sleep(2)
            self.pt_video.disconnect()
        except BrokenPipeError:
            print("Broken Pipe")
        except Exception as e:
            print(e)

    def start_video(self, num, serial_number):
        flag = True
        while flag:
            try:
                subprocess.call(['sudo', './start_single_cam.sh', f'start', f'{num}', f'{serial_number}'])
                time.sleep(2)
                self.pt_video = PeerTalkVideo(2346, 0, 2)
                if self.pt_video.connect(num) is False:
                    print("Problem with connection. Check application on the other side!")
                    time.sleep(1)
                    continue
                flag = False
            except BrokenPipeError:
                print("Broken Pipe")
            except Exception as e:
                print(e)
