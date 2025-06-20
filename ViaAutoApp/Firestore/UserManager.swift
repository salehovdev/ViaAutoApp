//
//  UserManager.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 03.07.25.
//

import Foundation
import FirebaseFirestore

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userFavoriteCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_post")
    }
    
    private func userFavoritePostDocument(userId: String, postId: String) -> DocumentReference {
        userFavoriteCollection(userId: userId).document(postId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    } ()
    
    func createNewUser(user: DatabaseUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    } ()
    
    func getNewUser(userId: String) async throws -> DatabaseUser {
        let snapshot = try await userDocument(userId: userId).getDocument(as: DatabaseUser.self)
        return snapshot
    }
    
    func updateUserProfileImage(userId: String, path: String) async throws {
        let data: [String: Any] = [
            DatabaseUser.CodingKeys.photoUrl.rawValue : path
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addUserFavoritePost(userId: String, postId: String) async throws {
        let document = userFavoriteCollection(userId: userId).document(postId)
        let documentId = document.documentID
        
        let data: [String: Any] = [
            UserFavoritePost.CodingKeys.id.rawValue : documentId,
            UserFavoritePost.CodingKeys.postId.rawValue : postId,
            UserFavoritePost.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func deleteUserFavoritePost(userId: String, postId: String) async throws {
        try await userFavoritePostDocument(userId: userId, postId: postId).delete()
    }
    
    func getAllFavoritePosts(userId: String) async throws -> [UserFavoritePost] {
        let snapshot = try await userFavoriteCollection(userId: userId).order(by: "date_created", descending: true).getDocuments()
        return try snapshot.documents.map { try $0.data(as: UserFavoritePost.self) }
    }
}
