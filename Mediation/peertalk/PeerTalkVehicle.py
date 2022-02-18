import struct
import threading
from typing import Type

from usbmux import USBMux
from peertalk.PeerTalkThreadBase import TPeerTalkThreadBase


class PeerTalkVehicle:

    mux = None
    p_sock = None
    pt_thread = None
    lock = threading.Lock()

    def __init__(self, *args):
        self.port = args[0]
        self.set_blocking = args[1]
        self.set_timeout = args[2]
        print("peerTalk Vehicle starting")
        self.mux = USBMux()

    def try_connect_abstract(self, class_to_instantiate: Type[TPeerTalkThreadBase]):
        print("Waiting for devices...")
        if not self.mux.devices:
            self.mux.process(1.0)
        if not self.mux.devices:
            print("No device found")

        dev = self.mux.devices[0]
        print("connecting to device %s" % str(dev))
        self.p_sock = self.mux.connect(dev, self.port)  # 2345
        if self.p_sock == -1:
            print("Maybe application on ios is down...")
            return False
        self.p_sock.setblocking(self.set_blocking)
        self.p_sock.settimeout(self.set_timeout)
        self.pt_thread = class_to_instantiate(self.p_sock, self.send)
        self.pt_thread.start()

        return True

    def send(self, r8, t_type, sock):
        with self.lock:
            header_values = (1, t_type, 0, len(r8) + 4)
            frame_structure = struct.Struct("! I I I I")
            packed_data = frame_structure.pack(*header_values)
            sock.send(packed_data)
            message_values = (len(r8), r8)
            fmt_string = "! I {0}s".format(len(r8))
            sm = struct.Struct(fmt_string)
            packed_message = sm.pack(*message_values)
            sock.send(packed_message)
