//
//  EditView.swift
//  TD
//
//  Created by Sharon Wolfovich on 07/02/2021.
//

import SwiftUI
import MapKit

/*protocol SaveAnnotationsDelegate {
    func saveContext()
}*/

struct EditViewOld: View {
    
    @State var mapType: MKMapType = .standard
    @Binding var selected: Int
    @State var alertMessage: AlertMessage = AlertMessage(title: "", message: "")
    @State var showingAlert: Bool = false
    @State private var selectedKey:String = "Map"
    let listMapTypes:[String:MKMapType] = ["Map":.standard, "Satellite":.satellite, "Hybrid":.hybrid]
    
    //let mapView = MapView()
    
    var body: some View {
        ZStack(alignment: .top){
            
            //mapView
            
            /*let mapView = MapView(showingAlert: self.$showingAlert,alertMessage: self.$alertMessage, mapType: self.$mapType)
    
            mapView.alert(isPresented: $showingAlert) { () -> Alert in
                //return Alert(title: Text("Important message"), message: Text("Go out and have a girlfriend!"), dismissButton:
                return Alert(title: Text(alertMessage.title), message: Text(alertMessage.message), dismissButton:.default(Text("Got it!")))
            }*/
            
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
                    })
                }
            }
        }.onDisappear(){
            showingAlert = true
            //self.mapView.saveContext()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EditViewOld(selected: .constant(0))
    }
}

