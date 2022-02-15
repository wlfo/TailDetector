//
//  DetectPointAnnotationView.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/02/2021.
//

import Foundation
import MapKit

class DetectPointAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //clusteringIdentifier = "detects"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        markerTintColor = UIColor.systemGreen
    }
}
