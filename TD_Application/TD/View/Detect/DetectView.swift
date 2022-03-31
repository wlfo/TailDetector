//
//  DetectView.swift
//  TD
//
//  Created by Sharon Wolfovich on 11/02/2021.
//

import SwiftUI
import MapKit
import CoreData
import Combine
import AVFoundation

struct DetectView: View, SegmentedMapTypeDelegate {
    @ObservedObject var instruction: DetectViewCoordinator.Instruction
    @ObservedObject var packetProcessor: PacketProcessor // Need to observe this object for PlateImageView
    @EnvironmentObject var ptc: PTCommandInterface
    @EnvironmentObject var ptvi: PTVehicleInterface
    @ObservedObject var drh = DataResetHelper.shared
    
    // FAC
    //@ObservedObject var factor: Factor
    
    @State var showDetailView: Bool = false
    @State var showStartButton = true
    @State var showPreview = true
    @State var showSinglePreview = true
    @State var offset = CGSize.zero
    @Binding var selected: TabName
    @State var alertMessage: AlertMessage = AlertMessage(title: "", message: "")
    @State var showingAlert: Bool = false
    
    
    // Todo: Has to be ObservableObject
    var mpCoordinator: DetectViewCoordinator!
    let mapView: DetectMapView!
    let MINIMUM_DETECT_ZONES = 3
    
    //static var askedToResetFlag = false
    
    init(selected: Binding<TabName>){
        let map = MKMapView()
        mpCoordinator = DetectViewCoordinator(map: map)
        mapView = DetectMapView(map: map, mpCoordinator: mpCoordinator)
        
        self.packetProcessor = mpCoordinator.packetProcessor
        self._selected = selected
        //self.peertalk.setPacketProcessor(pp: packetProcessor)
        
        // FAC
        //self.factor = mpCoordinator.getFactor()
        self.instruction = mpCoordinator.instruction!
    }
    
    func handleTap() {
        self.showDetailView = true
    }
    
    func changeMapType(mapType: MKMapType) {
        mapView.changeMapType(mapType: mapType)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            /// The Map View
            mapView
                .gesture(DragGesture(minimumDistance: 10)
                         // Support dragging map and stopping decentering
                            .onChanged { gesture in
                    self.mpCoordinator.setDecenter()
                }
                            .onEnded { gesture in
                }
                )
            
            // Top Layer above the Map View
            VStack {
                /// Top Bar - Map Type
                HStack(alignment: .top, spacing: 0) {
                    // License Plate Preview
                    VStack (alignment: .leading, spacing: 0){
                        PlateImageView(plateImage: $packetProcessor.plateImage, plateImageFrameColor: $packetProcessor.plateImageFrameColor,
                                       cameraId: $packetProcessor.cameraId)
                            .scaledToFit()
                            .onTapGesture {
                                self.handleTap()
                            }
                        
                        //LocationButton(map: self.mpCoordinator.map)
                        
                        
                    }.frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 160, maxWidth: 160, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 80, maxHeight: 80, alignment: .topLeading)
                    //.background(Color.red)
                    
                    
                    // Map Type Button
                    VStack {
                        //SegmentedMapTypeView(delegate: self)
                    }
                    .frame(minWidth: 80, maxWidth: .infinity)
                    
                    // Some Empty Space
                    VStack (){
                        
                        LocationButton(map: self.mpCoordinator.map)
                            .frame(width: 20, height: 20)
                            .padding(10)
                        
                    }
                    .frame(minWidth: 0, maxWidth: 45, alignment: .bottomTrailing)
                    
                    VStack (){
                        // Empty
                    }
                    .frame(minWidth: 0, maxWidth: 45)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                /// All Detection and Single Detection Previews
                VStack {
                    HStack() {
                        
                        // Indentation
                        /*
                        VStack {
                            //Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: 100)
                        .background(Color.blue)*/
                        
                        
                        VStack {
                            if self.showPreview {
                                // Detect Details
                                AllDetectionsPreview(packetProcessor: packetProcessor)
                                    .background(Color.white)
                                    .border(Color.black, width: 2)
                                    .onAppear(){
                                        
                                        
                                        
                                        
                                    }
                            } else if self.showSinglePreview || self.packetProcessor.revivePreview {
                                SingleDetectionPreview(packetProcessor: packetProcessor)
                                //SingleDetectionInstancesPreview(packetProcessor: packetProcessor)
                                    .background(Color.white)
                                    .border(Color.black, width: 2)
                                    .onAppear(){
                                        
                                        // Restore to initial state
                                        self.showSinglePreview = true
                                        self.packetProcessor.revivePreview = false
                                        
                                    }
                                
                            }
                            
                        }.frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: .infinity, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 240, maxHeight: 240)
                            .cornerRadius(5.0)
                            .offset(offset)
                        //.animation(.linear)
                            .gesture(DragGesture(minimumDistance: 80)
                                        .onChanged { value in
                                //self.offset = value.translation
                                self.showPreview = false
                                self.showSinglePreview = false
                                self.packetProcessor.revivePreview = false
                            }
                                        .onEnded { value in
                                //self.offset = CGSize.zero
                                self.showPreview = false
                                self.showSinglePreview = false
                                self.packetProcessor.revivePreview = false
                            }
                            )
                        
                        //.background(Color.gray)
                        
                        VStack {
                            //Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: 200)
                        .background(Color.blue)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(3.0)
                }//.background(Color.red)
                
                /// Start Button
                if self.showStartButton {
                    
                    Button(action: {
                        NSLog("Start Button Pressed")
                        if self.mpCoordinator.dpList.count < MINIMUM_DETECT_ZONES {
                            self.showingAlert = true
                        } else {
                            
                            Thread.detachNewThread {
                                
                                // Changing AppState to Detect State
                                let appState = Atomic<AppState>(AppState.shared)
                                appState.mutate { $0.state = .detect}
                                
                                // Set zone Zero
                                self.packetProcessor.setZoneZero()
                                
                                // Set Initial User Location for the initial detecting zone
                                self.mpCoordinator.setInitialUserLocation()
                                
                                // Test
                                //detectTest1()
                                
                                // Start Timed Location Tracking for Instruction Printing
                                self.mpCoordinator.startTimedLocationTracking(start: true)
                                
                                // Enable streaming of data
                                ptc.enablePublishing(enable: true)
                                ptvi.enablePublishing(enable: true)
                            }
                            
                            // Hide after started
                            self.showStartButton = false
                        }
                    })
                    {
                        HStack {
                            Image(systemName: "arrowtriangle.right")
                                .font(.title)
                            Text("Start")
                                .fontWeight(.semibold)
                                .font(.title)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(40)
                        .opacity(0.8)
                    }
                }
                
                Spacer()
                
                
                
                if !self.instruction.instruction.isEmpty {
                    VStack {
                        Text(self.instruction.instruction).font(.system(size: 20, weight: .heavy, design: .default)).padding(10).foregroundColor(Color.white)
                    }.background(Color.black).cornerRadius(10)
                }
            }
        }.onAppear(){
            
            // Load Annotations generated in EditView
            self.mapView.loadAnnotations()
            
            
        }.onReceive(drh.publisher, perform: { notification in
            if let value = notification.object as? Bool {
                if value {
                    self.ResetView()
                    self.instruction.instruction = ""
                }
            }
        })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Not Enough Detection Zones!"), message: Text("You must edit at least three detection zones."), dismissButton: .default(Text("OK!")))
            }
            .sheet(isPresented: self.$showDetailView) {
                PlateImageView(plateImage: $packetProcessor.plateImage, plateImageFrameColor: $packetProcessor.plateImageFrameColor, cameraId: $packetProcessor.cameraId)
            }
    }
    
    // Handle Reset all data of previuos detection process
    func ResetView() {
        // Unload All Annotations to Clear View
        self.mapView.unloadAnnotations()
        
        // Changing AppState to Detect State
        let appState = Atomic<AppState>(AppState.shared)
        appState.mutate { $0.state = .edit}
        
        // Reset all data in PacketProcessor
        self.packetProcessor.resetProcessor()
        
        // Restore previews to initial state
        self.showPreview = true
        self.showSinglePreview = false
        
        // Start Timed Location Tracking for Instruction Printing
        self.mpCoordinator.startTimedLocationTracking(start: false)
        
        // Disable streaming of data
        ptc.enablePublishing(enable: false)
        ptvi.enablePublishing(enable: false)
        
        // Show again Start Button
        self.showStartButton = true
    }
}

struct DetectView_Previews: PreviewProvider {
    static var previews: some View {
        DetectView(selected: .constant(TabName.Detect))
    }
}

// Testing
extension DetectView {
    func preparePacket(plateImageNamed: String, carImageNamed: String, plateNumber: String, latitude: Double, longitude: Double) -> Packet {
        let packet = Packet()
        packet.plateImage = UIImage(named: plateImageNamed)
        let loc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        packet.latitude = loc.latitude
        packet.longitude = loc.longitude
        packet.licensePlateNumber = plateNumber
        packet.fullImage = UIImage(named: carImageNamed)
        
        return packet
    }
    
    func launchPacket(packet: Packet, delay: UInt32, counter: Int){
        packet.make = "fffff"
        packet.city = "ddd"
        packet.country = "IL"
        packet.color = "Gray"
        packet.model = "Some Model"
        packet.year = "2020"
        //let ti = 8640 * counter // 114 minutes
        let ti = 1 * counter // 1 sec
        packet.timeStamp = Date().addingTimeInterval(TimeInterval(ti)) //Date.init(timeIntervalSince1970: 1000)
        sleep(delay)
        //DispatchQueue.main.async {
        self.packetProcessor.processPacket(packet: packet)
        //}
        
        usleep(100000)
    }
}
