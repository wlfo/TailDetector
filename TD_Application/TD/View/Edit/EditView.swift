//
//  EditMapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 13/02/2021.
//

import SwiftUI
import MapKit
import Combine
import CoreData

protocol AnnotationDataDelegate {
    func loadAnnotations()
    
    func unloadAnnotations()
}

struct EditView: View, SegmentedMapTypeDelegate {
    
    //@State var dragOffset = CGSize.zero
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) var listOfOne: FetchedResults<Settings>
    @ObservedObject var drh = DataResetHelper.shared
    @Environment(\.presentationMode) var presentation
    @Binding var selected: TabName
    
    //@State var openAlert: Bool = false
    
    let mapView: MapView!
    var mpCoordinator: MapViewCoordinator!
    
    init(selected: Binding<TabName>){
        let map = MKMapView()
        mpCoordinator = MapViewCoordinator(map: map)
        mapView = MapView(map: map, mpCoordinator: mpCoordinator)
        
        // Add user pinning handling
        let longPress = UILongPressGestureRecognizer(target: mpCoordinator, action: #selector(MapViewCoordinator.addAnnotation(gesture:)))
        longPress.minimumPressDuration = 0.4 //default is 0.5. 1
        map.addGestureRecognizer(longPress)
        
        // Tap for reseting edit->update state
        let tap = UITapGestureRecognizer(target: mpCoordinator, action: #selector(MapViewCoordinator.notifyUpdate(gesture:)))
        tap.numberOfTapsRequired = 1
        mpCoordinator.tapGestureRecognizer = tap
        map.addGestureRecognizer(tap)
        
        self._selected = selected
        
    }
    
    func changeMapType(mapType: MKMapType) {
        mapView.changeMapType(mapType: mapType)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            mapView
                .gesture(DragGesture(minimumDistance: 10)
                            // Support dragging map and stopping decentering
                            .onChanged { gesture in
                                //dragOffset = gesture.translation
                                self.mpCoordinator.setDecenter()
                            }
                            .onEnded { gesture in
                                //dragOffset = .zero
                            }
                )
            SegmentedMapTypeView(delegate: self)
        }.onDisappear(){
            
            //self.mapView.saveContext()
            self.presentation.wrappedValue.dismiss()
        }.onAppear(){
            
            // Take Radius settings and update DetectPointAnnotation before editing
            if self.listOfOne.count > 0 {
                DetectPointAnnotation.FENCE_RADIUS = Double(self.listOfOne[0].radius)
                DetectPointAnnotation.IN_POINT_RADIUS = Double(self.listOfOne[0].inRadius)
            }
            
            // Prevent App from Dim or Sleep
            UIApplication.shared.isIdleTimerDisabled = true
          
            // Receive notification to reset all data in view
        }.onReceive(drh.publisher, perform: { notification in
                        if let value = notification.object as? Bool {
                            if value {
                                self.ResetView()
                            }
                        }
        })
    }
    
    // Reset All data in view
    func ResetView() {
        // Unload All Annotations to Clear View
        self.mapView.unloadAnnotations()
    }
}

struct EditMapView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(selected: .constant(TabName.Edit))
    }
}
