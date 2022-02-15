//
//  ReplaceButtonView.swift
//  TD
//
//  Created by Sharon Wolfovich on 08/02/2021.
//

import SwiftUI

struct InnerCalloutView: View {
    var body: some View {
        HStack{
            VStack(spacing: 10) {
                Button(action: {
                    
                }, label: {
                    VStack {
                        Image(systemName: "pin")
                            .renderingMode(.original)
                        Text("Replace").fontWeight(.light)
                            .font(.subheadline)
                    }
                })
            }
            
            VStack(spacing: 10) {
                Button(action: {
                    
                }, label: {
                    VStack {
                        Image(systemName: "pin.slash.fill")
                        .renderingMode(.original)
                        Text("Remove").fontWeight(.light).font(.subheadline)
                    }
                })
            }
        }.padding().foregroundColor(.black) //.gray
        .background(Color.red)              //no bgcolor
    }
}

struct ReplaceButtonView_Previews: PreviewProvider {
    static var previews: some View {
        InnerCalloutView()
    }
}
