//
//  SegmentedMapTypeView.swift
//  TD
//
//  Created by Sharon Wolfovich on 13/02/2021.
//

import SwiftUI
import MapKit

protocol SegmentedMapTypeDelegate {
    func changeMapType(mapType: MKMapType)
}

struct SegmentedMapTypeView: View {
    //@State var mapType: MKMapType = .standard
    //@Binding var selected: Int
    @State private var selectedKey:String = "Map"
    let listMapTypes:[String:MKMapType] = ["Map":.standard, "Satellite":.satellite, "Hybrid":.hybrid]
    var delegate: SegmentedMapTypeDelegate
    
    var body: some View {
        VStack(){
            HStack{
                Picker("",selection:$selectedKey){
                    ForEach(listMapTypes.keys.sorted(), id: \.self){ value in
                        Text(value)
                    }
                }.scaledToFit()
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 189, height: 32, alignment: .center)
                .background(Color.white).cornerRadius(10.0)
                .onChange(of: selectedKey, perform: { value in
                    //self.mapType = listMapTypes[value]!
                    //mapView.changeMapType(mapType: listMapTypes[value]!)
                    delegate.changeMapType(mapType: listMapTypes[value]!)
                })
            }
        }
    }
}

class DummyDelegate: SegmentedMapTypeDelegate {
    func changeMapType(mapType: MKMapType) {
        print("dummy")
    }
}

struct SegmentedMapTypeView_Previews: PreviewProvider {
    
    static var previews: some View {
        SegmentedMapTypeView(delegate: DummyDelegate())
    }
}
