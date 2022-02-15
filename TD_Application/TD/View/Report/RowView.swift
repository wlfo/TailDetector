//
//  RowView.swift
//  TD
//
//  Created by Sharon Wolfovich on 15/02/2021.
//

import SwiftUI
import UIKit
import MapKit

struct RowView: View {
    @State var showDetailView: Bool = false
    
    let image: UIImage!
    let model: String!
    let licenseNumber: String!
    let year: String!
    let timeStamp: String!

    let detectedObject: DetectedObject!
    
    init(detectedObject: DetectedObject){
        self.detectedObject = detectedObject
        self.image = UIImage(data: detectedObject.locationArray[0].image!)
        self.model = detectedObject.model
        self.licenseNumber = detectedObject.licenseNumber
        self.year = detectedObject.year
        
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm E, d MMM y"
        self.timeStamp = formatter3.string(from: detectedObject.locationArray[0].timeStamp!)
        
    }
    
    func handleTap() {
        self.showDetailView = true
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 60)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .onTapGesture {
                        self.handleTap()
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(model)
                        .bold()
                    Text(licenseNumber)
                        .foregroundColor(.red)
                    Text(year)
                        .font(.caption)
                    
                }
                .padding(.top, 5)
                
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(timeStamp)
                        .bold()
                }
                .padding(.top, 5)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    //HStack (){
                    NavigationLink(destination: DetectedLocationsView(detectedObject: self.detectedObject)) {
                        
                    }.padding(.top, 5) // navlink
                    
                    //}
                    
                }// vstack
                
                .padding(.top, 5)
            } // hstack
            
            //vstack
        }.sheet(isPresented: self.$showDetailView) {
            // Placing breakpoint on the next line reveals that self.selectedEntry is nil,
            // as well as other state variables (not show) are not reflected accurately
            
            CarView(image: image, locationData: self.detectedObject.locationArray, detectedObject: self.detectedObject)
            
        } //sheet
    } //body
} //struct

