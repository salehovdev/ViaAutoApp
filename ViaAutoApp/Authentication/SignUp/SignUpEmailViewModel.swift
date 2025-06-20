//
//  SignUpEmailViewModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 27.06.25.
//

import Foundation

final class SignUpEmailViewModel: ObservableObject {
    
    @Published var emailText = ""
    @Published var passwordText = ""
    
    func signUp() async throws {
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            return
        }
        
        let auth = try await AuthenticationManager.shared.createUser(email: emailText, password: passwordText)
        let user = DatabaseUser(auth: auth)
        try await UserManager.shared.createNewUser(user: user)
    }
}
