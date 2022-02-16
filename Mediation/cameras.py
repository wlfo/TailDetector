from utils import Utils


def get_cameras():
    devices = Utils.cmdline("ls -l /dev/video* | grep -v grep | cut -d/ -f3").decode("utf-8")
    device_list = devices.splitlines()
    return device_list
