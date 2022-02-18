from enum import Enum


class TransmissionType(Enum):
    DEVICE_INFO = 100
    MESSAGE = 101
    PING = 102
    PONG = 103
    COMMAND = 104
    IMAGE = 105
