import struct
from typing import Type

from SimpleStreamerThread import SimpleStreamerThread
from usbmux import USBMux


class PeerTalkVideo:

    mux = None
    p_sock = None
    pt_thread = None
    dev = None

    def __init__(self, *args):
        self.port = args[0]
        self.set_blocking = args[1]
        self.set_timeout = args[2]
        print("peerTalk starting")
        self.mux = USBMux()

    def connect(self, num):
        print("Waiting for devices...")
        if not self.mux.devices:
            self.mux.process(1.0)

        if self.dev is None:
            self.dev = self.mux.devices[0]

        print("connecting to device %s" % str(self.dev))
        self.p_sock = self.mux.connect(self.dev, self.port)
        if self.p_sock == -1:
            print("Maybe application on ios is down...")
            return False
        self.p_sock.setblocking(self.set_blocking)
        self.p_sock.settimeout(self.set_timeout)
        self.pt_thread = SimpleStreamerThread(self.p_sock, self.send, num)
        self.pt_thread.start()

        return True

    def disconnect(self):
        if not self.mux.devices:
            return

        if self.dev is None:
            return

        self.pt_thread.stop()
        self.p_sock.close()
        self.p_sock = -1

    def send(self, r8, t_type, sock):
        header_values = (1, t_type, 0, len(r8) + 4)
        frame_structure = struct.Struct("! I I I I")
        packed_data = frame_structure.pack(*header_values)
        sock.send(packed_data)
        message_values = (len(r8), r8)
        fmt_string = "! I {0}s".format(len(r8))
        sm = struct.Struct(fmt_string)
        packed_message = sm.pack(*message_values)
        sock.send(packed_message)
