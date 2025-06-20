//
//  ProfileViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 28.06.25.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var providers: [ProviderOption] = []
    @Published private(set) var user: DatabaseUser? = nil
    @Published var authUser: AuthDataResultModel? = nil
    @Published var url: URL? = nil
    
    func loadUser() async throws {
        let auth = try AuthenticationManager.shared.getUser()
        self.user = try await UserManager.shared.getNewUser(userId: auth.uid)
    }
    
    func loadProviders() {
        if let providers = try? AuthenticationManager.shared.getProvider() {
            self.providers = providers
        }
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.logOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
    func changePassword(password: String) async throws {
        try await AuthenticationManager.shared.changePassword(password: password)
    }
    
    func changeEmail(email: String) async throws {
        try await AuthenticationManager.shared.changeEmail(email: email)
    }
    
    func linkEmail(email: String, password: String) async throws {
        let result = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        self.authUser = result
    }
    
    func linkGoogle() async throws {
        let helper = GoogleSignInHelper()
        let tokens = try await helper.signIn()
        let result = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.authUser = result
    }
    
    func linkApple() async throws {
        let helper = AppleSignInHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let result = try await AuthenticationManager.shared.linkApple(tokens: tokens)
        self.authUser = result
    }
    
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImageToFirebase(data: data, userId: user.userId)
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, path: path)
            
            self.url = url
        }
    }
}
