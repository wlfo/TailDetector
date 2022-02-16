import threading
import cv2
import socket
from peertalk.TransmissionType import TransmissionType


class SimpleStreamerThread(threading.Thread):
    def __init__(self, *args):
        self._stop = threading.Event()
        self.p_sock = args[0]
        self.send_func = args[1]
        self.cap = cv2.VideoCapture(int(args[2]))
        self._running = True
        threading.Thread.__init__(self)

        # function using _stop function

    def stop(self):
        self._running = False
        self._stop.set()

    def stopped(self):
        return self._stop.isSet()

    def run(self):
        # Check if camera was opened correctly
        if not (self.cap.isOpened()):
            print("Could not open video device")

        # Set the resolution
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        #print("Setting fps rate result is {result}".format(result=self.cap.set(cv2.CAP_PROP_FPS, 10)))

        scale_percent = 60 #50

        # Capture frame-by-frame
        counter = 0
        while True:
            try:
                if self.stopped():
                    self.cap.release()
                    break

                ret, frame = self.cap.read()

                if frame is None:
                    continue

                # calculate the <scale_percent> percent of original dimensions
                width = int(frame.shape[1] * scale_percent / 100)
                height = int(frame.shape[0] * scale_percent / 100)

                # d_size
                d_size = (width, height)

                # resize image
                output = cv2.resize(frame, d_size)

                # Display the resulting frame
                if frame is not None:
                    image_bytes = cv2.imencode('.jpg', output)[1].tobytes()
                    print("sending {count}".format(count=len(image_bytes)))
                    self.send_func(image_bytes, TransmissionType.IMAGE.value, self.p_sock)
            except socket.timeout:
                print("Timeout Exception Occurred in: {name}".format(name=self.__class__.__name__))
            except BrokenPipeError:
                print("Broken Pipe")
                self.cap.release()
                break
            except Exception as e:
                print("Exception Occurred in: {name}".format(name=self.__class__.__name__))
                print(e)
                if e.args[0] == 104:
                    self.cap.release()
                    break
                pass

