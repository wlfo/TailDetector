//
//  PTVehicleInterface.swift
//  TD
//
//  Created by Sharon Wolfovich on 03/07/2021.
//

import Foundation
import peertalk
import UIKit
import os

class PTVehicleInterface: PTInterfaceBase {
    @Published var group: JSONCustomStruct.Response?
    @Published var image: UIImage!
    
    private var enablePublishingFlag = false
    static let shared = PTVehicleInterface()
    private var scheduleCheck: RepeatingTimer?
    private override init(){}
    
    func setup(){
        
        // Vehicle recognition Channel peertalk port
        super.setup(port: 2347)
    }
    
    func enablePublishing(enable: Bool){
        self.enablePublishingFlag = enable
    }
    
    override func handleTransmission(payload: Data?, transmissionType: Frame){
        switch transmissionType {
        case .message:
            print("nothing")
            guard let payload = payload else {
                return
            }
            payload.withUnsafeBytes { buffer in
                let textBytes = buffer[(buffer.startIndex + MemoryLayout<UInt32>.size)...]
                
                if let message = String(bytes: textBytes, encoding: .utf8) {
                    do {
                        
                        let response: JSONCustomStruct.Response? = JSONGroupParser.parse(jsonString: message, type: JSONCustomStruct.Response.self) as? JSONCustomStruct.Response
                        
                        if let res = response {
                            self.group = res
                            if (self.enablePublishingFlag){ // Move upward because parsing not needed if not publishing
                                Thread.detachNewThread {
                                    
                                    // Build Packet object from jetson data
                                    let packet: Packet = PacketBuilder.buildPacket(group: res)
                                    
                                    // Get current location from this device and not from jetson
                                    let currentLocation = self.packetProcessor?.dropDelegate.getUserLocation()
                                    packet.latitude = currentLocation?.coordinate.latitude
                                    packet.longitude = currentLocation?.coordinate.longitude
                                    self.packetProcessor?.processPacket(packet: packet)
                                }
                            }
                        } else {
                            print("Something went wrong with parsing json : \(message)")
                            os_log("Something went wrong with parsing json %@", log: myLog, type:.error, String(message))
                        }
                    }
                    
                    self.append(output: "Reached Message")
                }
            }
            
        case .image:
            guard let payload = payload else {
                return
            }
            payload.withUnsafeBytes { buffer in
                let imageBytes = Data(buffer[(buffer.startIndex + MemoryLayout<UInt32>.size)...])
                image = UIImage(data: imageBytes)
            }
            
        default:
            append(output: "Reached Default")
            break
        }
    }
}
