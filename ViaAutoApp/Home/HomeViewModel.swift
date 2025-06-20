//
//  HomeViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 07.07.25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var posts: [CarPostModel] = []
    
    func getAllPosts() async throws {
        self.posts = try await PostManager.shared.getAllPosts()
    }
}
