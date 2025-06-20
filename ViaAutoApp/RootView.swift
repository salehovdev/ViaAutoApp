//
//  RootView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 28.06.25.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TabbarView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let user = try? AuthenticationManager.shared.getUser()
            self.showSignInView = user == nil
            
            try? AuthenticationManager.shared.getProvider()
        }
        .fullScreenCover(isPresented: $showSignInView) {
            SignInView(showSignInView: $showSignInView)
        }
    }
}

#Preview {
    RootView()
}
