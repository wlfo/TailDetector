//
//  RemoveButtonView.swift
//  TD
//
//  Created by Sharon Wolfovich on 08/02/2021.
//

import SwiftUI

struct RemoveButtonView: View {
    var body: some View {
        VStack(spacing: 10) {
            
            
            Button(action: {
                
            }, label: {
                VStack {
                    Image(systemName: "pin.slash.fill")
                        //.renderingMode(.original)
                    Text("Remove")
                }
            })
            
        }
    }
}

struct RemoveButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveButtonView()
    }
}
