//
//  EmptyView.swift
//  TD
//
//  Created by Sharon Wolfovich on 11/03/2021.
//

import SwiftUI
import os

struct CamerasView: View {
    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @State private var selection: String?
    
    static let myLog = OSLog(subsystem: "proudhon.td", category: "testing")
    
    var body: some View {
        VStack {
            HStack (alignment: .top){
                List (self.cameras, id:\.self) { camera in
                    VStack{
                        HStack {
                            Text(camera.location)
                            NavigationLink(destination: CameraStreamView(deviceNum: "\(String(camera.videoDeviceNumber)) \(camera.deviceSerialNumber)")) {
                            }
                        }
                    }
                }
            }
        }.onAppear(){
            os_log("iOS App initialized successfully!", log: CamerasView.myLog, type:.info)
            os_log("iOS App initialized successfully debug!", log: CamerasView.myLog, type:.debug)
        }.onDisappear(){
            //print("DAEMON UP:\(ptc.daemon)")
        }
    }
}
