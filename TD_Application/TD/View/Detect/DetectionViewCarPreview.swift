//
//  DetectionViewCarPreview.swift
//  TD
//
//  Created by Sharon Wolfovich on 25/02/2021.
//

import SwiftUI

struct DetectionViewCarPreview: View {
    let image: UIImage!
    @State var showDetailView: Bool = false
    
    func handleTap() {
        self.showDetailView = true
    }
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    self.handleTap()
                }
        }.sheet(isPresented: self.$showDetailView) {
            ImageFullView(image: image)
        }
    }
}
