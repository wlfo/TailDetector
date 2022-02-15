//
//  CustomCalloutView.swift
//  TailDetector
//
//  Created by Sharon Wolfovich on 20/01/2021.
//

import SwiftUI
import MapKit

class CustomCalloutView: UIView {
    
    //#1
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // #2
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    // #3
    public convenience init(image: UIImage, title: String) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    @objc func onTap() {
        print("Hello --------------")
    }
    
}
