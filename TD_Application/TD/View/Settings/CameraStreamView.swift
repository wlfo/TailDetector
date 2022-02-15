//
//  CameraStream.swift
//  TD
//
//  Created by Sharon Wolfovich on 17/05/2021.
//

import SwiftUI
import os

struct CameraStreamView: View {
    @ObservedObject var ptvi: PTVideoInterface = PTVideoInterface.shared
    @ObservedObject var ptc: PTCommandInterface = PTCommandInterface.shared
    @State var disableButton = false
    @State private var orientation = UIDeviceOrientation.unknown
    
    static let myLog = OSLog(subsystem: "proudhon.td", category: "testing")
    var deviceNum: String?
    
    init(deviceNum: String){
        self.deviceNum = deviceNum
    }
    var body: some View {
        HStack(alignment: .top){
            VStack{
                if self.disableButton != true {
                    Button("Start Camera Connection"){
                        self.disableButton = true
                        ptc.sendCommand(command: "start_video \(deviceNum ?? "0")")
                    }.disabled(self.disableButton || ptvi.image != nil)
                }
                
                HStack (alignment: .top){
                    if (ptvi.image != nil){
                        Image(uiImage: ptvi.image)
                            .resizable()
                            .scaledToFit()//Fill()
                            .aspectRatio(contentMode: .fit)
                            //.frame(width: 1280, height: 720)
                            .border(Color.black, width: 4)
                            .cornerRadius(4)
                    }
                }
            }
            
        }.onAppear(){
            //pt.sendCommand(command: "stream_video\(deviceNum ?? "0")")
            //ptg.sendCommand(command: "start_video\(deviceNum ?? "0")")
        }.onDisappear(){
            ptc.sendCommand(command: "stop_video")
            self.disableButton = false
            ptvi.image = nil
        }
    }
}
