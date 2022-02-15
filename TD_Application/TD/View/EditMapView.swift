//
//  EditMapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 13/02/2021.
//

import SwiftUI
import MapKit

/*protocol SaveAnnotationsDelegate {
 func saveContext()
 }*/

struct EditView: View, SegmentedMapTypeDelegate {

    @Binding var selected: Int
    let mapView: MapView!
    
    init (selected: Binding<Int>){
        let map = MKMapView()
        let mpCoordinator = MapViewCoordinator(map: map)
        mapView = MapView(map: map, mpCoordinator: mpCoordinator)
        self._selected = selected
    }
    
    func changeMapType(mapType: MKMapType) {
        mapView.changeMapType(mapType: mapType)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            mapView
            SegmentedMapTypeView(delegate: self)
        }.onDisappear(){
            //showingAlert = true
            self.mapView.saveContext()
        }
    }
}

struct EditMapView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(selected: .constant(0))
    }
}
