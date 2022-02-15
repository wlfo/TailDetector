//
//  CarView.swift
//  TD
//
//  Created by Sharon Wolfovich on 15/02/2021.
//

import SwiftUI


struct CarView: View {
    let image: UIImage!//String!
    var locationData: [LocationData]
    var detectedObject: DetectedObject?
    
    
    @State var showDetailView: Bool = false
    
    func handleTap() {
        self.showDetailView = true
    }
    
    func formatDate(date: Date) -> String{
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm E, d MMM y"
        return formatter3.string(from: date)
    }
    
    var body: some View {
        VStack (alignment: .leading){
            //Image(image)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    self.handleTap()
                }
            //RowView(image: "car1", model: "BMW some", licenseNumber: "7VIG263", year: "2020", timeStamp: "17:45:24")
            
            HStack {
                Text("Model:").foregroundColor(.gray)
                Text(self.detectedObject?.model ?? "")
            }.padding(5)
            
            HStack {
                Text("Year:").foregroundColor(.gray)
                Text(self.detectedObject?.year ?? "")
            }.padding(5)
            
            HStack {
                Text("LicenseNumber:").foregroundColor(.gray)
                Text(self.detectedObject?.licenseNumber ?? "").foregroundColor(.red)
            }.padding(5)

            
            ForEach(self.locationData) { loc in
                HStack {
                    Text("Seen:").foregroundColor(.gray)
                    Text(formatDate(date: loc.timeStamp!))
                }.padding(5)
            }
        }.padding(3)
        .sheet(isPresented: self.$showDetailView) {
            // Placing breakpoint on the next line reveals that self.selectedEntry is nil,
            // as well as other state variables (not show) are not reflected accurately
            
            ImageFullView(image: image)
            
        }
    }
}

