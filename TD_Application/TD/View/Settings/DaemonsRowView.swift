//
//  DaemonsView.swift
//  TD
//
//  Created by Sharon Wolfovich on 19/05/2021.
//

import SwiftUI

struct DaemonsRowView: View {
    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @ObservedObject var ptc: PTCommandInterface = PTCommandInterface.shared
    @State var currentState:Bool = false
    @State var isDisplayed: Bool
    @State var alertMessage: AlertMessage = AlertMessage(title: "", message: "")
    @State var showingAlert: Bool = false
    
    var title: String = ""
    var body: some View {
        
        HStack {
            
            Image(uiImage: UIImage(systemName: "gearshape.2")!)
                .resizable()
                .frame(width: 30, height: 20)
                .aspectRatio(contentMode: .fit)
            Spacer()
            Spacer()
            Spacer()
            Toggle(ptc.daemon ? "Stop All Daemons" : "Start All Daemons" , isOn: .init(
                get: { ptc.daemon },//isDisplayed },
                set: {
                    isDisplayed = $0
                    print("changed")
                    if (ptc.daemon){
                        // Todo: Maybe send command to PTVideoWrapper
                        ptc.sendCommand(command: "stop_daemon")
                        //ptv.sendCommand(command: "reset_video")
                    } else {
                        
                        var camerasMap: String = ""
                        for camera in self.cameras.enumerated(){
                            camerasMap += [camera.element.deviceSerialNumber, String(camera.element.videoDeviceNumber)].joined(separator: ":")
                            camerasMap += ","
                        }
                        
                        if camerasMap.count > 0 {
                            camerasMap.removeLast()
                        }
                        
                        // Sending Date to Jetson
                        let date = Date()
                        let dateString = getDateString(date: date)
                        print("date is \(dateString)")
                        
                        let commandPrefix = ["start_daemon", camerasMap].joined(separator: " ")
                        // Todo: Maybe send command to PTVideoWrapper
                        ptc.sendCommand(command: [commandPrefix, dateString].joined(separator: " "))
                    }
                    
                }
            ))
        }
        
    }
    
    func getDateString(date: Date) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "y-MM-dd_HH:mm:ss.990"
        return formatter3.string(from: date)
    }
}
