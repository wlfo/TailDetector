//
//  AppState.swift
//  TD
//
//  Created by Sharon Wolfovich on 28/01/2021.
//

import Foundation

public class AppState: NSObject, ObservableObject {
    static let shared = AppState()
    enum State {
        case edit
        case detect
        case report
    }
    
    @Published var state: State = State.edit
    
    private override init(){}
    
}
