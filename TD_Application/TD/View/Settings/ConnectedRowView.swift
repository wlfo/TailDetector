//
//  ConnectedRowView.swift
//  TD
//
//  Created by Sharon Wolfovich on 02/05/2021.
//

import SwiftUI

struct ConnectedRowView: View {
    @EnvironmentObject var ptc: PTCommandInterface
    @State var currentState:Bool = false
    var title: String = ""
    var body: some View {
        
        HStack() {
            Image(uiImage: UIImage(systemName: "laptopcomputer.and.iphone")!)
                .resizable()
                .frame(width: 30, height: 20)
                .aspectRatio(contentMode: .fit)
            
            Toggle(isOn:self.$ptc.connected, label: {
                Spacer()
                Spacer()
                Text(self.ptc.connected ? "Jetson Connected" : "Jetson Disconnected")
            }).disabled(true)
        }
    }
}

struct ConnectedRowView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedRowView(title: "connected raw view")
    }
}
