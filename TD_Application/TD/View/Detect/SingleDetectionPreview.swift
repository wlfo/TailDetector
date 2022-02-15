//
//  SingleDetectionPreview.swift
//  TD
//
//  Created by Sharon Wolfovich on 26/02/2021.
//

import SwiftUI

struct SingleDetectionPreview: View {
    @ObservedObject var packetProcessor: PacketProcessor
    @State var offset = CGSize.zero
    
    func getDateString(date: Date) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm:ss"//"HH:mm E, d MMM y"
        return formatter3.string(from: date)
    }
    
    var body: some View {
        
        ZStack {
            
            if packetProcessor.detectPreviewDetails != nil {
                let packet = packetProcessor.getSingleDetectedForView()
                VStack (alignment: .leading){
                    DetectViewCarPreview(image: packetProcessor.getSingleDetectedForView().fullImage)
                    
                    HStack {
                        Text("Model:").fontWeight(.thin)
                        Text(packet.model).fontWeight(.heavy)
                    }
                    
                    HStack {
                        Text("Year:").fontWeight(.thin)
                        Text(packet.year).fontWeight(.heavy)
                    }
                    
                    HStack {
                        Text("Color:").fontWeight(.thin)
                        Text(packet.color).fontWeight(.heavy)
                    }
                    
                    HStack {
                        Text("Make:").fontWeight(.thin)
                        Text(packet.make).fontWeight(.heavy)
                    }
                    
                    HStack {
                        Text("Plate:").fontWeight(.thin)
                        Text(packetProcessor.getSingleDetectedForView().licensePlateNumber).fontWeight(.heavy).foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("First seen:").fontWeight(.thin)
                        Text(getDateString(date: packet.timeStamp)).fontWeight(.heavy)
                    }
                    
                    HStack {
                        Text("Location:").fontWeight(.thin)
                        //Text("\(packet.country ?? ""), \(packet.city ?? ""), \(packet.street ?? "")").fontWeight(.thin).font(.subheadline)
                        Text("\(packet.city ?? ""), \(packet.street ?? "")").fontWeight(.thin).font(.subheadline)
                    }
                }.padding(3.0)
            }
        }
        
    }
}
