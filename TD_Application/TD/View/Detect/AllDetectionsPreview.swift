//
//  DetectDetailsPreview.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/02/2021.
//

import SwiftUI
import AVFoundation

struct AllDetectionsPreview: View {
    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @ObservedObject var packetProcessor: PacketProcessor
    @State var offset = CGSize.zero
    
    func matchCamera(cameraId: Int32) -> String {
        for camera in cameras {
            if (camera.videoDeviceNumber == cameraId){
                return camera.location
            }
        }
        
        return "Camera Unknown"
    }
    
    func getDateString(date: Date) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm:ss"//"HH:mm E, d MMM y"
        return formatter3.string(from: date)
    }
    var body: some View {
        
        ZStack {
            if packetProcessor.detectionsCount > 0 {
                VStack (alignment: .leading, spacing: 6) {
                    HStack (alignment: .top, spacing: 6) {
                        VStack{
                            Text("\(packetProcessor.detectionsCount)")
                                .frame(width: 25, height: 25, alignment: .center)
                                .padding(3)
                                .font(.title2)
                                .foregroundColor(.black)
                                .background(Color.white)
                            //.cornerRadius(10.0)
                                .border(Color.red, width: 5)
                            
                            
                            
                        }
                        .cornerRadius(5.0)
                        .padding(3)
                        
                        VStack {
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Spacer()
                    }.onAppear(){
                        AudioServicesPlayAlertSound(SystemSoundID(1325))
                    }
                    
                }.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            }
            
            ScrollView (.vertical){
                ForEach(packetProcessor.getDetectedsForPreview()) { dataForView in//packetProcessor.detectPreviewDetailsArray) { dataForView in
                    
                    
                    VStack (alignment: .leading){
                        DetectionViewCarPreview(image: dataForView.fullImage)
                        
                        HStack {
                            Text("Model:").fontWeight(.thin)
                            Text(dataForView.model).fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Year:").fontWeight(.thin)
                            Text(dataForView.year).fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Color:").fontWeight(.thin)
                            Text(dataForView.color).fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Plate:").fontWeight(.thin)
                            Text(dataForView.licensePlateNumber).fontWeight(.heavy).foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("First seen:").fontWeight(.thin)
                            Text(getDateString(date: dataForView.timeStamp)).fontWeight(.heavy)
                        }
                        HStack (alignment: .top){
                            Text("Location:").fontWeight(.thin)
                            Text("\(dataForView.country ?? ""), \(dataForView.city ?? ""), \(dataForView.street ?? "")").fontWeight(.thin).font(.subheadline)
                        }
                        
                        HStack {
                            Text("Camera:").fontWeight(.thin)
                            Text("\( matchCamera(cameraId: dataForView.cameraId))").fontWeight(.heavy)
                        }
                    }.padding(3.0)
                }
            }
        }
    }
}
