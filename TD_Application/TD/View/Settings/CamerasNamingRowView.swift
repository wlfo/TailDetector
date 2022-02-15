//
//  CamerasNamingView.swift
//  TD
//
//  Created by Sharon Wolfovich on 06/07/2021.
//

import SwiftUI

struct CamerasNamingRowView: View {
    var body: some View {
        HStack() {
            Image(uiImage: UIImage(systemName: "video.fill")!)
                .resizable()
                .frame(width: 30, height: 20)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
            Spacer()
            Spacer()
            Spacer()
            Text("Define Camera")
            
            VStack{
                NavigationLink(destination: CamerasNamingView()) {
                }}.disabled(PTCommandInterface.shared.daemon)//.disabled(ptc.daemon)
        }
    }
}
