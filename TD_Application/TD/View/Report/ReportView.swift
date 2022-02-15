//
//  ReportView.swift
//  TD
//
//  Created by Sharon Wolfovich on 15/02/2021.
//

import SwiftUI
import CoreData

struct ReportView: View {
    @Binding var selected: TabName
    @FetchRequest(entity: DetectedObject.entity(), sortDescriptors: [], predicate: NSPredicate(format: "detectType == %d", DetectedAnnotation.DetectType.car.rawValue)) var detectedCarObjects: FetchedResults<DetectedObject>
    
    @FetchRequest(entity: DetectedObject.entity(), sortDescriptors: [], predicate: NSPredicate(format: "detectType == %d", DetectedAnnotation.DetectType.uncertain.rawValue)) var detectedUncertainObjects: FetchedResults<DetectedObject>
    
    var body: some View {
        NavigationView{
            List {
                
                /// High likelihood of surveillance
                Section(header: Text("High likelihood of surveillance")){
                    
                    if detectedCarObjects.count == 0 {
                        Text("No Detections Found")
                    } else {
                        ForEach(detectedCarObjects, id: \.self) { dob in
                            if dob.dType == DetectedAnnotation.DetectType.car {
                                //RowView(image: UIImage(data: dob.locationArray[0].image!), model: dob.model, licenseNumber: dob.licenseNumber, year: dob.year, timeStamp: "17:45:24")
                                RowView(detectedObject: dob)
                            }
                        }
                    }
                }
                
                /// Undetermined risk
                Section(header: Text("Undetermined risk")){
                    if detectedUncertainObjects.count == 0 {
                        Text("No Uncertain Detections Found")
                    } else {
                        ForEach(detectedUncertainObjects, id: \.self) { dob in
                            if dob.dType == DetectedAnnotation.DetectType.uncertain {
                                //RowView(image: UIImage(data: dob.locationArray[0].image!), model: dob.model, licenseNumber: dob.licenseNumber, year: dob.year, timeStamp: "\(dob.locationArray[0].timeStamp)")
                                RowView(detectedObject: dob)
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Report", displayMode: .inline)
        }
    }
    
    // Todo: Clear all data from view
    func ResetView() {
        
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(selected: .constant(TabName.Report))
    }
}
