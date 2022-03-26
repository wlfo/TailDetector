//
//  SwiftUIView.swift
//  TD
//
//  Created by Sharon Wolfovich on 11/03/2021.
//

import SwiftUI

struct SettingsView: View {
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) var listOfOne: FetchedResults<Settings>
    @Binding var selected: TabName
    @State var radius = 200
    @State var inRadius = 50
    

    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let drh = DataResetHelper.shared
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Jetson Settings")){
                    ConnectedRowView()
                    CamerasRowView()
                    CamerasNamingRowView()
                    ALPRDaemonRowView()
                    DaemonsRowView(isDisplayed: false)
                }
                
                
                Section(header: Text("App Settings")){
                    Stepper("Detect Radius \(self.radius)m", value: $radius, in: 0...2000, step: 200, onEditingChanged: {_ in
                        DetectZoneAnnotation.FENCE_RADIUS = Double(self.radius)
                    })
                    Stepper("In zone Radius \(self.inRadius)m", value: $inRadius, in: 0...200, step: 50, onEditingChanged: {_ in
                        DetectZoneAnnotation.IN_ZONE_RADIUS = Double(self.inRadius)
                    })
                    
                    // Row view to enable Recency filter of subsequent packets
                    RecencyRowView()
                    
                    Button("Reset All Data"){
                        // Delete previous context
                        appDelegate?.removeObjects(entity: AnnotationData.self, sortKey: "index")
                        appDelegate?.removeObjects(entity: DetectedObject.self, sortKey: "uuid")
                        
                        // Send notification to all observers
                        self.drh.reset()
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }.onAppear(){
            if self.listOfOne.count > 0 {
                self.radius = Int(self.listOfOne[0].radius)
                self.inRadius = Int(self.listOfOne[0].inRadius)
            }
        }
        .onDisappear(){
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let context = appDelegate.persistentContainer.viewContext
            
            if self.listOfOne.count > 0 {
                listOfOne[0].inRadius = Int32(self.inRadius)
                listOfOne[0].radius = Int32(self.radius)
                
            } else {
                _ = Settings(context: context, inRadius: Int32(self.inRadius), radius: Int32(self.radius))
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
