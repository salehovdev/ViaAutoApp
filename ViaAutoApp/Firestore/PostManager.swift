//
//  PostManager.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 06.07.25.
//

import Foundation
import FirebaseFirestore

final class PostManager {
    
    static let shared = PostManager()
    private init() { }
    
    private let postCollection = Firestore.firestore().collection("posts")
    
    private func postDocument(postId: String) -> DocumentReference {
        postCollection.document(postId)
    }
    
    func uploadPost(post: CarPostModel) async throws {
        try postDocument(postId: post.id).setData(from: post, merge: false)
    }
    
    func getAllPosts() async throws -> [CarPostModel] {
        try await postCollection.getQueryPosts(as: CarPostModel.self)
    }
    
    func getPost(postId: String) async throws -> CarPostModel {
        try await postDocument(postId: postId).getDocument(as: CarPostModel.self)
    }
}

extension Query {
    
    func getQueryPosts<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        let snapshot = try await self.order(by: "date", descending: true).getDocuments()
        
        return try snapshot.documents.map { post in
            try post.data(as: T.self)
        }
    }
}
