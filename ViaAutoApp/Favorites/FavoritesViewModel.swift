//
//  FavoritesViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 10.07.25.
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published private(set) var posts: [(userFavoritePost: UserFavoritePost, post: CarPostModel)] = []
    @Published var favoritePostIds: Set<String> = []
    
    func addUserFavoritePost(postId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getUser()
            try? await UserManager.shared.addUserFavoritePost(userId: authDataResult.uid, postId: postId)
            favoritePostIds.insert(postId)
        }
    }
    
    func deleteFavorites(postId: String) {
        Task {
            let user = try AuthenticationManager.shared.getUser()
            try? await UserManager.shared.deleteUserFavoritePost(userId: user.uid, postId: postId)
            favoritePostIds.remove(postId)
            getFavoritePosts()
        }
    }
    
    func getFavoritePosts() {
        Task {
            let user = try AuthenticationManager.shared.getUser()
            let userFavoritePosts = try await UserManager.shared.getAllFavoritePosts(userId: user.uid)
            
            var localArray: [(userFavoritePost: UserFavoritePost, post: CarPostModel)] = []
            var favoritePostIds: Set<String> = []
            
            for userFavoritePost in userFavoritePosts {
                favoritePostIds.insert(userFavoritePost.postId)
                if let post = try? await PostManager.shared.getPost(postId: userFavoritePost.postId) {
                    localArray.append((userFavoritePost, post))
                }
            }
            
            self.posts = localArray
            self.favoritePostIds = favoritePostIds
        }
    }
}
