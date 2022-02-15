//
//  CamerasNamingView.swift
//  TD
//
//  Created by Sharon Wolfovich on 06/07/2021.
//

import SwiftUI

struct CamerasNamingView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @State private var openSheet: Bool = false
    @State private var action: EditCameraView.Action = EditCameraView.Action.add
    @State private var currentCamera: Camera?
    
    var body: some View {
        VStack(spacing: 15) {
            Button("Add Camera", action: {
                self.openSheet = true
                self.action = EditCameraView.Action.add
            })
            
            ScrollView(.vertical){
                
                ForEach(cameras, id: \.self) { value in
                    VStack (alignment: .leading) {
                        HStack {
                            VStack (alignment: .leading){
                                HStack {
                                    Text("Serial Number: ")
                                    Text(value.deviceSerialNumber).bold()
                                }
                                HStack {
                                    Text("Location: ")
                                    Text(value.location).bold()
                                }
                                
                                HStack {
                                    Text("Video Number: ")
                                    Text(String(value.videoDeviceNumber))
                                }
                                
                            }
                            
                            Spacer()
                            
                            VStack (alignment: .center) {
                                
                                // Edit
                                Button(action: {
                                    self.openSheet = true
                                    self.action = EditCameraView.Action.edit
                                    self.currentCamera = value
                                }, label: {
                                    VStack {
                                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                            .renderingMode(.original)
                                        Text("Edit").fontWeight(.light)
                                            .font(.headline)
                                    }
                                })
                                
                            }
                            
                            VStack (alignment: .trailing) {
                                
                                // Delete
                                Button(action: {
                                    /*guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                                     let context = appDelegate.persistentContainer.viewContext*/
                                    context.delete(value)
                                    if context.hasChanges {
                                        do {
                                            try context.save()
                                        } catch {
                                            let nserror = error as NSError
                                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                        }
                                    }
                                }, label: {
                                    VStack {
                                        Image(systemName: "trash.fill")
                                            .renderingMode(.original)
                                        Text("Delete").fontWeight(.light)
                                            .font(.headline)
                                    }
                                })
                                
                            }
                            
                        }
                        Divider()
                    }
                }
                
                Spacer()
                
                
            }.padding()
                .sheet(isPresented: $openSheet){
                    EditCameraView(action: self.$action, currentCamera: self.$currentCamera)
                }
        }
    }
}
