//
//  LocationButton.swift
//  TD
//
//  Created by Sharon Wolfovich on 08/03/2021.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct LocationButton: UIViewRepresentable {
   
    var map: MKMapView!

    init(map: MKMapView){
        self.map = map
    }
    
    func makeUIView(context: Context) -> MKUserTrackingButton {
        let userTrackingButton = MKUserTrackingButton(mapView: self.map)

        return userTrackingButton
    }

    func updateUIView(_ uiView: MKUserTrackingButton, context: Context) {
        
    }
}
