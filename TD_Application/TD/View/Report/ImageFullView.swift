//
//  FullView.swift
//  TD
//
//  Created by Sharon Wolfovich on 17/02/2021.
//

import SwiftUI

struct ImageFullView: View {
    let image: UIImage!//String!
    
    var body: some View {
        VStack {
            //Image(image)
            Image(uiImage: image)
            
            
        }.padding()
        
        
    }
}
