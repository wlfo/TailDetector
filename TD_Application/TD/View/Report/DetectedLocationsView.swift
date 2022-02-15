//
//  ReportMapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 17/02/2021.
//

import SwiftUI
import MapKit

struct DetectedLocationsView: View {
    
    @Environment(\.presentationMode) var presentation
    var mpCoordinator: ReportViewCoordinator!
    let mapView: ReportMapView!
    let lp: String!
    let detectedObject: DetectedObject!
    let map: MKMapView!
    
    init(detectedObject: DetectedObject){
        map = MKMapView()
        map.showsUserLocation = false
        mpCoordinator = ReportViewCoordinator(map: map)
        mapView = ReportMapView(map: map, mpCoordinator: mpCoordinator)
        self.lp = detectedObject.licenseNumber
        self.detectedObject = detectedObject
    }
    
    var body: some View {
        ZStack(alignment: .top){
            /// The Map View
            mapView
        }.onAppear(){
            self.mpCoordinator.addAnnotations(detectedObject: self.detectedObject)
        }.onDisappear(){
            self.map.removeAnnotations(self.map.annotations)
            self.presentation.wrappedValue.dismiss()
        }
    }
}
