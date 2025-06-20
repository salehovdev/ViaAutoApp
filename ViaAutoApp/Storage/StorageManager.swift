//
//  StorageManager.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 07.07.25.
//

import Foundation
import SwiftUI
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    func getImageData(from path: String) async throws -> Data {
        try await getPathForImage(path: path).data(maxSize: 5 * 1024 * 1024)
    }
    
    func getData(userId: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    // for profile image
    func saveImageToFirebase(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        
        let returnedData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedData.path, let returnedName = returnedData.name else {
            throw FirebaseError.userError
        }
        
        return (returnedPath, returnedName)
    }
    
    //for new post
    func savePostImageToFirebase(data: Data, userId: String, postId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let fileName = UUID().uuidString + ".jpeg"
        let pathRef = storage
            .child("users")
            .child(userId)
            .child("posts")
            .child(postId)
            .child(fileName)
        
        let result = try await pathRef.putDataAsync(data, metadata: meta)
        
        guard let path = result.path, let name = result.name else {
            throw FirebaseError.userError
        }
        
        return (path, name)
    }
    
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 1) else { throw FirebaseError.userError }
        
        return try await saveImageToFirebase(data: data, userId: userId)
    }
}
