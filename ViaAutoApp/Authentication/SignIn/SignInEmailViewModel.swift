//
//  SignInEmailViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 27.06.25.
//

import Foundation

final class SignInEmailViewModel: ObservableObject {
    
    @Published var emailText = ""
    @Published var passwordText = ""
    
    func signIn() async throws {
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            return
        }
        
        try await AuthenticationManager.shared.signIn(email: emailText, password: passwordText)
    }
}
