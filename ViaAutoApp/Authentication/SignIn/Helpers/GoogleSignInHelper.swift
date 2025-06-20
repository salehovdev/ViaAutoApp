//
//  GoogleSignInHelper.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 29.06.25.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class GoogleSignInHelper {
    func signIn() async throws -> GoogleSignInModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw FirebaseError.userError
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = result.user.idToken?.tokenString else {
            throw FirebaseError.userError
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        guard let name = result.user.profile?.name else { throw FirebaseError.userError }
        guard let email = result.user.profile?.email else { throw FirebaseError.userError }
        
        let tokens = GoogleSignInModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return tokens
    }
}
