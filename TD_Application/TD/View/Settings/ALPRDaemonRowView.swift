//
//  ALPRDaemonView.swift
//  TD
//
//  Created by Sharon Wolfovich on 13/05/2021.
//

import SwiftUI

struct ALPRDaemonRowView: View {
    @ObservedObject var peertalk: PTCommandInterface = PTCommandInterface.shared
    @State var currentState:Bool = false
    var title: String = ""
    var body: some View {
        
        HStack() {
            Image(uiImage: UIImage(systemName: "gearshape.2")!)
                .resizable()
                .frame(width: 30, height: 20)
                .aspectRatio(contentMode: .fit)
            Toggle(isOn:$peertalk.daemon, label: {
                Spacer()
                Spacer()
                Text(self.peertalk.daemon ? "ALPRDaemon is Up" : "ALPRDaemon is Down")
            }).disabled(true)
        }
    }
}

struct ALPRDaemonView_Previews: PreviewProvider {
    static var previews: some View {
        ALPRDaemonRowView()
    }
}
