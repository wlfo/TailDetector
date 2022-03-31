//
//  SingleDetectionInstancesView.swift
//  TD
//
//  Created by Sharon Wolfovich on 06/03/2021.
//

import SwiftUI

struct SingleDetectionInstancesPreview: View {
    
    @ObservedObject var packetProcessor: PacketProcessor
    @State var offset = CGSize.zero
    
    func getDateString(date: Date) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm E, d MMM y"
        return formatter3.string(from: date)
    }
    
    var body: some View {
        
        ScrollView (.vertical){
            
            let packet = packetProcessor.getSingleDetectedForView()
            let packets = packetProcessor.identifiersHashTable.retrieveValue(for: packet.licensePlateNumber)
            
            VStack(alignment: .leading) {
                if packetProcessor.detectPreviewDetails != nil {
                    HStack {
                        Text("Instances:").fontWeight(.thin)
                        Text("\(packets!.count)").fontWeight(.heavy)
                    }
                }
                HStack {
                    Text("Model:").fontWeight(.thin)
                    Text(packet.model).fontWeight(.heavy)
                }
                
                HStack {
                    Text("Year:").fontWeight(.thin)
                    Text(packet.year).fontWeight(.heavy)
                }
                
                HStack {
                    Text("Plate:").fontWeight(.thin)
                    Text(packet.licensePlateNumber).fontWeight(.heavy).foregroundColor(.red)
                }
            }.padding(3.0)
            
            ForEach(packets!) { dataForView in
                VStack (alignment: .leading){
                    DetectionViewCarPreview(image: dataForView.fullImage)
                    
                    if dataForView.licensePlateNumber != packet.licensePlateNumber {
                        HStack {
                            Text("Plate:").fontWeight(.thin)
                            Text(dataForView.licensePlateNumber).fontWeight(.heavy).foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Text("Seen:").fontWeight(.thin)
                        Text(getDateString(date: packet.timeStamp)).fontWeight(.heavy)
                    }
                    HStack (alignment: .top){
                        Text("Location:").fontWeight(.thin)
                        Text("\(dataForView.country ?? ""), \(dataForView.city ?? ""), \(dataForView.street ?? "")").fontWeight(.thin).font(.subheadline)
                    }
                }.padding(3.0)
            }
        }
    }
}

