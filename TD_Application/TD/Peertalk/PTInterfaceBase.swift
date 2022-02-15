//
//  PTInterfaceBase.swift
//  TD
//
//  Created by Sharon Wolfovich on 03/07/2021.
//

import Foundation
import peertalk
import UIKit
import os

class PTInterfaceBase: NSObject, ObservableObject {
    
    @Published var messageReceived: String = ""
    @Published var listening: Bool = false
    @Published var connected: Bool = false
    
    private var serverChannel: PTChannel?
    private var peerChannel: PTChannel?
    public var packetProcessor: PacketProcessor?
    let myLog = OSLog(subsystem: "proudhon.td", category: "peertalk")
    
    enum Frame: UInt32 {
        case deviceInfo = 100
        case message = 101
        case ping = 102
        case pong = 103
        case command = 104
        case image = 105
    }
    
    func setup(port: in_port_t){
        self.objectWillChange.send()
        // Create a new channel that is listening on our IPv4 port
        let channel = PTChannel(protocol: nil, delegate: self)
        channel.listen(on: port, IPv4Address: INADDR_LOOPBACK) { error in
            if error != nil {
                self.listening = false
                os_log("Failed to connect to port %@", log: self.myLog, type:.error, String(port))
            } else {
                self.serverChannel = channel
                self.listening = true
                os_log("Success connect to port %@", log: self.myLog, type:.error, String(port))
            }
        }
    }

    // Sending command string to Jetson
    func sendCommand(command: String) {
        if let peerChannel = peerChannel {
            var m = command
            let payload = m.withUTF8 { buffer -> Data in
                var data = Data()
                data.append(CFSwapInt32HostToBig(UInt32(buffer.count)).data)
                data.append(buffer)
                return data
            }
            
            // Sending Command using Command enum
            peerChannel.sendFrame(type: Frame.command.rawValue, tag: 0, payload: payload, callback: nil)
        } else {
            
            // Todo: Handle other manner because append construct JSON
            //append(output: "Cannot send message - not connected")
            
        }
    }
    
    // Handle textual received messages
    func append(output message: String) {
        self.objectWillChange.send()
        self.messageReceived = message
    }
    
    // Abstract func
    func handleTransmission(payload: Data?, transmissionType: Frame){}
    
    func cleanup(){}
    
    func setPacketProcessor(pp: PacketProcessor){
        self.packetProcessor = pp
    }
}

extension PTInterfaceBase: PTChannelDelegate {
    
    // Receive
    func channel(_ channel: PTChannel, didRecieveFrame type: UInt32, tag: UInt32, payload: Data?) {
        if let transmissionType = Frame(rawValue: type) {
                
            // Here switch case
            //switch transmissionType {
            //case .message:
            // ...
            
            handleTransmission(payload: payload, transmissionType: transmissionType)
        }
    }
    
    
    func channel(_ channel: PTChannel, shouldAcceptFrame type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        guard channel == peerChannel else {
            return false
        }
        guard let frame = Frame(rawValue: type),
              frame == .command || frame == .ping || frame == .message || frame == .image else {
            print("Unexpected frame of type: \(type)")
            return false
        }
        return true
    }
    
    func channel(_ channel: PTChannel, didAcceptConnection otherChannel: PTChannel, from address: PTAddress) {
        peerChannel?.cancel()
        peerChannel = otherChannel
        peerChannel?.userInfo = address
        
        os_log("Connect to port %@", log: self.myLog, type:.error, String(address.port))
        self.connected = true
        
    }
    
    func channelDidEnd(_ channel: PTChannel, error: Error?) {
        if error != nil {
            // Todo: Handle other manner because append construct JSON
            //append(output: "\(channel) ended with \(error)")
        } else {
            objectWillChange.send()
            self.connected = false
            cleanup()
        }
    }
}

extension FixedWidthInteger {
    var data: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout.size(ofValue: self))
    }
}


extension NSData {
    public func convertToBytes() -> [UInt8] {
        let count = self.length / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        self.getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
}

