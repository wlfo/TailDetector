//
//  DetectedAnnotationView.swift
//  TD
//
//  Created by Sharon Wolfovich on 23/02/2021.
//

import Foundation
import MapKit

private let multiWheelCycleClusterID = "multiWheelCycle"

class CarAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "unicycleAnnotation"

    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "carAnno"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor(named: "carColor")
        glyphImage = UIImage(systemName: "car.2")
    }
}

class UncertainAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "uncertainAnno"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = multiWheelCycleClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: DisplayConfiguration
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor(named: "uncertainColor")
        glyphImage = UIImage(systemName: "questionmark.video")
    }
}

class FootAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "footAnno"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = multiWheelCycleClusterID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor(named: "footColor")
        glyphImage = UIImage(systemName: "person.2")
    }
}


 
