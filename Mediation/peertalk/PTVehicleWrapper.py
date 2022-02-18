import threading
from peertalk.PeerTalkThreadBase import PeerTalkThreadBase


class PTVehicleWrapper(PeerTalkThreadBase):

    def __init__(self, *args):
        self.p_sock = args[0]
        self.send_func = args[1]
        self._running = True
        threading.Thread.__init__(self)

    def handle_generic_command(self, command):
        print("In Vehicle Wrapper, Not expecting command: %s" % command)
