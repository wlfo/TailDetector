import threading
import struct
from peertalk.TransmissionType import TransmissionType
from typing import TypeVar


class PeerTalkThreadBase(threading.Thread):
    def __init__(self, *args):
        self.p_sock = args[0]
        self.send_func = args[1]
        self._running = True
        threading.Thread.__init__(self)

    def handle_generic_command(self, command):
        pass

    def generate_response(self, command, inner_response):
        response = '{{ "command" : "{cmd}", "response" : "{res}" }}'.format(cmd=command, res=inner_response)
        return response

    def run(self):
        frame_structure = struct.Struct("! I I I I")
        while self._running:
            try:
                msg = self.p_sock.recv(16)
                if len(msg) > 0:
                    # Structure: (_, type   , _, payload size )
                    # Structure: (_, MESSAGE, _, /0x20 + /0x10)
                    frame = frame_structure.unpack(msg)
                    size = frame[3]
                    msg_data = self.p_sock.recv(size)
                    transmission_type = frame[1]
                    body = msg_data[4:]

                    # Command sent from edge device
                    if transmission_type == TransmissionType.COMMAND.value:
                        command = body.decode('utf-8')
                        self.handle_generic_command(command)

            except Exception as e:
                print("Exception Occurred in: {name}".format(name=self.__class__.__name__))
                print(e)
                if e.args[0] == 104:
                    self.finish_inner_threads()
                pass

    def stop(self):
        self._running = False

    def finish_inner_threads(self):
        pass


TPeerTalkThreadBase = TypeVar("TPeerTalkThreadBase", bound=PeerTalkThreadBase)
