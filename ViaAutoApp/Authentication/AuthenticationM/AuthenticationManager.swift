//
//  AuthenticationManager.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 27.06.25.
//

import Foundation
import FirebaseAuth

enum FirebaseError: Error {
    case userError
}

enum ProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func getUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else { throw FirebaseError.userError }
        return AuthDataResultModel(user: user)
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { throw FirebaseError.userError }
        
        try await user.delete()
    }
    
    func getProvider() throws -> [ProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw FirebaseError.userError
        }
        
        var providers: [ProviderOption] = []
        for provider in providerData {
            if let option = ProviderOption(rawValue: provider.providerID) {
                providers.append(option)
                print(provider.providerID)
            } else {
                assertionFailure()
            }
        }
        
        return providers
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
    func changePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.userError
        }
        
        try await user.updatePassword(to: password)
    }
    
    func changeEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.userError
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: - Sign in SSO
extension AuthenticationManager {
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let result = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: result.user)
    }
    
    @discardableResult
    func signInGoogle(tokens: GoogleSignInModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInApple(tokens: AppleSignInModel) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: ProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
}

// MARK: - Sign in Anonymous
extension AuthenticationManager {
    
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: AppleSignInModel) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: ProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.userError
        }
        
        let result = try await user.link(with: credential)
        return AuthDataResultModel(user: result.user)
    }
}
