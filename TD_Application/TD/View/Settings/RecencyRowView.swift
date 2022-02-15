//
//  RecencyRowView.swift
//  TD
//
//  Created by Sharon Wolfovich on 12/08/2021.
//

import SwiftUI

struct RecencyRowView: View {
    
    @State private var recencyOn: Bool = true
    
    var body: some View {
        VStack (alignment: .leading, spacing: .none){
            Toggle(isOn:$recencyOn, label: {
                Text(self.recencyOn ? "Recency Filter Turned On" : "Recency Filter Turned On")
            }).disabled(false)
            .onChange(of: recencyOn) { value in
                PacketProcessor.applyRecencyCheck = value
            }
        }
    }
}

struct RecencyRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecencyRowView()
    }
}
