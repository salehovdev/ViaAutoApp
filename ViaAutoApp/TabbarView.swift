//
//  ContentView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 20.06.25.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("New Post", systemImage: "plus.circle.fill") {
                NewPostView()
            }
            
            Tab("Favorites", systemImage: "heart.fill") {
                FavoritesView()
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    TabbarView(showSignInView: .constant(false))
}
