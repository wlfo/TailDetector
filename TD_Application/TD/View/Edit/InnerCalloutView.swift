//
//  ReplaceButtonView.swift
//  TD
//
//  Created by Sharon Wolfovich on 08/02/2021.
//

import MapKit
import SwiftUI

protocol ReplaceRemoveDelegate {
    func buttonUpdate(tag: Int)
    func buttonDelete(tag: Int)
}

struct InnerCalloutView: View {
    @GestureState private var tap = false
    @State private var isPressed = false
    
    var delegate:ReplaceRemoveDelegate!
    var tag: Int!
    
    //var coordinator: MKMapViewDelegate!
    
    var body: some View {
        HStack{
            VStack(spacing: 10) {
                Button(action: {
                    
                    delegate.buttonUpdate(tag: tag)
                }, label: {
                    VStack {
                        Image(systemName: "pin")
                            .renderingMode(.original)
                        Text("Replace").fontWeight(.light)
                            .font(.caption2)
                    }
                }).tag("Replace")
            }
            
            VStack(spacing: 10) {
                Button(action: {
                    delegate.buttonDelete(tag: tag)
                }, label: {
                    VStack {
                        Image(systemName: "pin.slash.fill")
                        .renderingMode(.original)
                        Text("Remove").fontWeight(.light)
                            .font(.caption2)
                    }
                }).tag("Remove")
            }
        }.padding().foregroundColor(.black) //.gray
        .background(Color.red)
        //no bgcolor
    }
}

struct ReplaceButtonView_Previews: PreviewProvider {
    static var previews: some View {
        InnerCalloutView()
    }
}
