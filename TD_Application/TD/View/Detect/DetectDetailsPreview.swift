//
//  DetectDetailsPreview.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/02/2021.
//

import SwiftUI


struct AllDetectionsPreview: View {
    
    @ObservedObject var packetProcessor: PacketProcessor 
    //@State var showDetailView: Bool = false
    @State var offset = CGSize.zero
    
    /*func handleTap() {
        self.showDetailView = true
    }*/
    
    var body: some View {
        
        ZStack {
            if packetProcessor.detectionsCount > 0 {
                VStack (alignment: .leading, spacing: 6) {
                    HStack (alignment: .top, spacing: 6) {
                        ZStack{
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
                    }
                    
                }.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            }
     
            ScrollView (.vertical){
                ForEach(packetProcessor.getDetectedsForPreview()) { dataForView in//packetProcessor.detectPreviewDetailsArray) { dataForView in
                    VStack (alignment: .leading){
                        
                        DetectViewCarPreview(image: dataForView.fullImage)
                        
                        HStack {
                            Text("Model:").fontWeight(.thin)
                            Text("BMW some").fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Year:").fontWeight(.thin)
                            Text("2020").fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Plate:").fontWeight(.thin)
                            Text(dataForView.licensePlateNumber).fontWeight(.heavy).foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("First seen:").fontWeight(.thin)
                            Text("17:45:24").fontWeight(.heavy)
                        }
                    }.padding(3.0)
                }
                
            }
        }
        
    }
}
