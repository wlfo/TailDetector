//
//  SettingsRowView.swift
//  TD
//
//  Created by Sharon Wolfovich on 11/03/2021.
//

import SwiftUI
import UIKit

struct CamerasRowView: View {
    var title: String = ""
    var body: some View {
        HStack() {
            Image(uiImage: UIImage(systemName: "questionmark.video")!)
                .resizable()
                .frame(width: 30, height: 20)
                .aspectRatio(contentMode: .fit)
            Spacer()
            Spacer()
            Spacer()
            Text("Cameras View")
            VStack{
                NavigationLink(destination: CamerasView()) {
                }}.disabled(PTCommandInterface.shared.daemon)//.disabled(ptc.daemon)
        }
    }
}
