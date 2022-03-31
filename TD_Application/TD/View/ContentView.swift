//
//  ContentView.swift
//  TailDetector
//
//  Created by Sharon Wolfovich on 17/01/2021.
//

import SwiftUI
import MapKit
import UIKit

enum TabName: Hashable {
    case Edit
    case Detect
    case Report
    case Settings
}

struct ContentView: View {
    
    @State private var selectedView: TabName = TabName.Edit
    
    var body: some View {
        
        TabView(selection: $selectedView) {
            EditView(selected: $selectedView)
                .tabItem({
                            Image(systemName: "mappin.and.ellipse")
                            Text("Edit") }).tag(TabName.Edit)
            
            
            DetectionView(selected: $selectedView)
                .tabItem({
                            Image(systemName: "car.2.fill")
                            Text("Detect") }).tag(TabName.Detect)
            
            
            ReportView(selected: $selectedView)
                .tabItem({
                            Image(systemName: "list.and.film")
                            Text("Report") }).tag(TabName.Report)
            
            
            SettingsView(selected: $selectedView)
                .tabItem({
                            Image(systemName: "gear")
                            Text("Settings") }).tag(TabName.Settings)
        }.edgesIgnoringSafeArea(.top).background(Color.white)
    }
}
