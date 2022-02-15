//
//  PTAltVideoInterface.swift
//  TD
//
//  Created by Sharon Wolfovich on 08/06/2021.
//


import Foundation
import peertalk
import UIKit

class PTVideoInterface: PTInterfaceBase {
    @Published var image: UIImage!
    
    static let shared = PTVideoInterface()
    private var scheduleCheck: RepeatingTimer?
    
    private override init(){}
    
    override func cleanup() {
        self.image = nil
    }
    
    func setup(){
        // Video Channel peertalk port
        super.setup(port: 2346)
        
        // Schedule Checking Jetson components status
        self.scheduleCheck = RepeatingTimer(timeInterval: 5)
        self.scheduleCheck!.eventHandler = {
            print("Timer Fired")
            if (self.connected){
                // Todo: Perform all checks against Jetson
                self.sendCommand(command: "ping")
            } else {
                // Not connected to Jetson peertalk and cannot perform any checks
            }
        }
        
        self.scheduleCheck!.resume()
    }
    
    override func handleTransmission(payload: Data?, transmissionType: Frame){
        switch transmissionType {
        case .image:
            guard let payload = payload else {
                return
            }
            payload.withUnsafeBytes { buffer in
                let imageBytes = Data(buffer[(buffer.startIndex + MemoryLayout<UInt32>.size)...])
                image = UIImage(data: imageBytes)
            }
            
        default:
            break
        }
    }
}
