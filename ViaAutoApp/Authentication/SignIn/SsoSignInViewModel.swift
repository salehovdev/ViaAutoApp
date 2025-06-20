//
//  SsoSignInViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 28.06.25.
//

import CryptoKit
import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import AuthenticationServices

@MainActor
final class SsoSignInViewModel: NSObject, ObservableObject {
    
    @Published var didSignInApple: Bool = false
    
    private var currentNonce: String?
    private var completionHandler: ((Result<AppleSignInModel, Error>) -> Void)? = nil
    
    func signInAnonymous() async throws {
        let auth = try await AuthenticationManager.shared.signInAnonymous()
        let user = DatabaseUser(auth: auth)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInGoogle() async throws {
        
        let helper = GoogleSignInHelper()
        let tokens = try await helper.signIn()
        let auth = try await AuthenticationManager.shared.signInGoogle(tokens: tokens)
        let user = DatabaseUser(auth: auth)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInApple() async throws {
        
        let helper = AppleSignInHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let auth = try await AuthenticationManager.shared.signInApple(tokens: tokens)
        let user = DatabaseUser(auth: auth)
        try await UserManager.shared.createNewUser(user: user)
    }
    
}
