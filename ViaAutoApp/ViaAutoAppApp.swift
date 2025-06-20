//
//  ViaAutoAppApp.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 20.06.25.
//

import SwiftUI
import Firebase

@main
struct ViaAutoAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
