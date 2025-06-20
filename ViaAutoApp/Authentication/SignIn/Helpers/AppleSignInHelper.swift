//
//  AppleSignInHelper.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 29.06.25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI

@MainActor
final class AppleSignInHelper: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<AppleSignInModel, Error>) -> Void)? = nil
    
    func startSignInWithAppleFlow() async throws -> AppleSignInModel {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(completion: @escaping (Result<AppleSignInModel, Error>) -> Void) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(FirebaseError.userError))
            return
        }
        
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = topVC as? any ASAuthorizationControllerPresentationContextProviding
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionHandler?(.failure(FirebaseError.userError))
            return
        }
        
        let name = appleIDCredential.fullName?.givenName
        let email = appleIDCredential.email
        
        let tokens = AppleSignInModel(token: idTokenString, nonce: nonce, name: name, email: email)
          
        completionHandler?(.success(tokens))
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Sign in with Apple errored: \(error)")
            completionHandler?(.failure(FirebaseError.userError))
        }
    }
}

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
