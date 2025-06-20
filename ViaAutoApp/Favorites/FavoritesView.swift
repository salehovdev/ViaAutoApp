//
//  FavoritesView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI

struct FavoritesView: View {
    
    let colomns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colomns) {
                    ForEach(viewModel.posts, id: \.post.id) { post in
                        NavigationLink {
                            CarDetailView(post: post.post)
                        } label: {
                            PostCardView(post: post.post, favoriteVM: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.getFavoritePosts()
            }
        }
    }
}

#Preview {
    FavoritesView()
}
