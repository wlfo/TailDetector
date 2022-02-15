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

class PTCommandInterface: PTInterfaceBase {
    
    @Published var daemon: Bool = false
    @Published var group: JSONCustomStruct.Response?
    @Published var cameras: Entities.Cameras?
    @Published var image: UIImage!
    
    private var enablePublishingFlag = false
    static let shared = PTCommandInterface()
    private var scheduleCheck: RepeatingTimer?
    
    private override init(){}
    
    func setup(){
        
        // Command Channel peertalk port
        super.setup(port: 2345)
        
        // Schedule Checking Jetson components status
        self.scheduleCheck = RepeatingTimer(timeInterval: 5)
        self.scheduleCheck!.eventHandler = {
            print("Timer Fired")
            if (self.connected){
                // Todo: Perform all checks against Jetson
                self.sendCommand(command: "get_cameras_details")
                
                // Todo: Fix all the way - return values from Jetson have different struct - parser will crash
                self.sendCommand(command: "is_daemon_up")
            } else {
                // Not connected to Jetson peertalk and cannot perform any checks
            }
        }
        
        self.scheduleCheck!.resume()
    }
    
    override func handleTransmission(payload: Data?, transmissionType: Frame){
        switch transmissionType {
        case .command:
            guard let payload = payload else {
                return
            }
            
            payload.withUnsafeBytes { buffer in
                let textBytes = buffer[(buffer.startIndex + MemoryLayout<UInt32>.size)...]
                if let message = String(bytes: textBytes, encoding: .utf8) {
                    let commandResult: Parser.Command = Parser.parseCommandResponse(jsonString: message)
                    handleCommand(command: commandResult)
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
    
    func handleCommand(command: Parser.Command){
        switch command.command {
        case "is_daemon_up":
            let commandResult: Entities.ALPRDaemonUP = Parser.parse(jsonString: command.response, type: Entities.ALPRDaemonUP.self) as! Entities.ALPRDaemonUP
            self.daemon = commandResult.is_up
        case "get_cameras_details":
            let commandResult: Entities.Cameras = Parser.parse(jsonString: command.response, type: Entities.Cameras.self) as! Entities.Cameras
            self.cameras = commandResult
        default:
            break
        }
    }
    
    func enablePublishing(enable: Bool){
        self.enablePublishingFlag = enable
    }
}
