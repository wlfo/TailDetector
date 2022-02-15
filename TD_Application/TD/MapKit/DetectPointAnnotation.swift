//
//  DetectPointAnnotation.swift
//  TailDetector
//
//  Created by Sharon Wolfovich on 18/01/2021.
//

import MapKit
import SwiftUI
import Combine

class DetectPointAnnotation: MKPointAnnotation {
    
    var state = State.edit(value: .newAtEdge)
    var fence: MKCircle!
    var route: MKRoute!
    var annotationData: AnnotationData!
    static var FENCE_RADIUS = 200.0 // If inside this range it means that I am inside the point (for detection purposes)
    static var IN_POINT_RADIUS = 50.0 // If inside this range it means that I visited the point (for instruction purposes)

    var uuid: UUID! {
        get {
            annotationData.uuid
        }
    }
    var index: Int! {
        
        set {
            annotationData.index = Int32(newValue)
        }
        
        get {
            Int(annotationData.index)
        }
        
    }
    
    override var title: String? {
        set{
            annotationData.title = newValue
            super.title = newValue
        }
        get{
            return super.title
        }
    }
    
    override var coordinate: CLLocationCoordinate2D {
        set {
            annotationData.latitude = newValue.latitude
            annotationData.longitude = newValue.longitude
            super.coordinate = CLLocationCoordinate2D(latitude: annotationData.latitude, longitude: annotationData.longitude)
        }
        
        get {
            return super.coordinate
        }
    }
    
    enum State {
        case edit(value: EditState)
        case detect
        case report
    }
    
    enum EditState {
        case newAtEdge
        case update
        case remove
        case noaction
    }
    
    init(annotationData: AnnotationData) {
        super.init()
        self.annotationData = annotationData
        //self.uuid = uuid
        //self.index = index
        self.coordinate = CLLocationCoordinate2D(latitude: annotationData.latitude, longitude: annotationData.longitude)
        self.title = annotationData.title
        self.fence = MKCircle(center: self.coordinate, radius: CLLocationDistance(DetectPointAnnotation.FENCE_RADIUS))
    }
}

extension DetectPointAnnotation.EditState: Equatable {
    
    public static func ==(lhs: DetectPointAnnotation.EditState, rhs: DetectPointAnnotation.EditState) -> Bool {
        
        switch (lhs,rhs) {
        case (.newAtEdge, .newAtEdge):
            return true
        case (.noaction, .noaction):
            return true
        case (.remove, .remove):
            return true
        case (.update, .update):
            return true
        
        default:
            return false
        }
    }
}

extension DetectPointAnnotation.State: Equatable {
    
    public static func ==(lhs: DetectPointAnnotation.State, rhs: DetectPointAnnotation.State) -> Bool {
        
        switch (lhs,rhs) {
        case (.detect, .detect):
            return true
        case (.report, .report):
            return true
        case (.edit(let a), .edit(let b)):
            return a == b
        default:
            return false
        }
    }
}

