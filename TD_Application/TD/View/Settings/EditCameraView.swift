//
//  AddCameraView.swift
//  TD
//
//  Created by Sharon Wolfovich on 06/07/2021.
//

import SwiftUI

struct EditCameraView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @Binding var action: Action
    @Binding var currentCamera: Camera?
    @State private var deviceSerialNumber: String = ""
    @State private var location: String = ""
    @State private var videoDeviceNumber: String = ""
    @Environment(\.presentationMode) var presentation
    
    enum Action {
        case add
        case edit
    }
    
    var body: some View {
        VStack(spacing: 15) {
            
            if (self.action == .add) {
                Text("Add New Camera") .font(.largeTitle)
            } else {
                Text("Edit Existing Camera") .font(.largeTitle)
            }
            
            TextField("Device Serial Number", text: $deviceSerialNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Camera Location", text: $location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("......", text: $videoDeviceNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle()).disabled(true)
            
            HStack {
                Spacer()
                Button("Save Camera") {
                    let dsn = self.deviceSerialNumber.trimmingCharacters(in: .whitespaces)
                    let loc = self.location.trimmingCharacters(in: .whitespaces)
                    let vdn = self.videoDeviceNumber.trimmingCharacters(in: .whitespaces)
                    
                    if let _vdn = Int32(vdn), !deviceSerialNumber.isEmpty, !location.isEmpty {
                        /*guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                        let context = appDelegate.persistentContainer.viewContext*/
                        
                        if (self.action == .add){
                            _ = Camera(context: context, deviceSerialNumber: dsn, location: loc, videoDeviceNumber: _vdn)
                        } else {
                            self.currentCamera?.deviceSerialNumber = self.deviceSerialNumber
                            self.currentCamera?.location = self.location
                            self.currentCamera?.videoDeviceNumber = Int32(self.videoDeviceNumber)!
                        }
                        
                        // Rearange video device number
                        for (i, camera) in cameras.enumerated() {
                            camera.videoDeviceNumber = Int32(i)
                        }
                        
                        
                        if context.hasChanges {
                            do {
                                try context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                        
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            }
            Spacer()
            
        }.padding(20)
        .onAppear(){
            if (self.action == .edit){
                self.deviceSerialNumber = self.currentCamera!.deviceSerialNumber
                self.location = self.currentCamera!.location
                self.videoDeviceNumber = String(self.currentCamera!.videoDeviceNumber)
            } else {
                self.videoDeviceNumber = String(self.cameras.count)
            }
        }
    }
}
