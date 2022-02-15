//
//  PlateImageView.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import SwiftUI

struct PlateImageView: View {

    @FetchRequest(entity: Camera.entity(), sortDescriptors: []) var cameras: FetchedResults<Camera>
    @Binding var plateImage: UIImage!
    @Binding var plateImageFrameColor: UIColor!
    @Binding var cameraId: Int32!
    
    func matchCamera(cameraId: Int32) -> String {
        for camera in cameras {
            if (camera.videoDeviceNumber == cameraId){
                return camera.location
            }
        }
        
        return "Camera Unknown"
    }
    
    var body: some View {
        if plateImage != nil {
            VStack (spacing: 0){
                Image(uiImage: plateImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.init(plateImageFrameColor), lineWidth: 4))
                
                if let _ = cameraId {
                    Text(matchCamera(cameraId: cameraId)).italic().bold().padding(0)
                }
                
            }
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.init(plateImageFrameColor), lineWidth: 4)
            )
        }
    }
}
