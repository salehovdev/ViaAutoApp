//
//  SignUpView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI

struct SignUpView: View {
    
    @StateObject var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    
    @State private var passwordHidden: Bool = true
    @State private var signInView: Bool = false
    
    var body: some View {
        ZStack {
            if !signInView {
                signUpView
                    .transition(.move(edge: .trailing))
            } else {
                SignInView(showSignInView: $showSignInView)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: signInView)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    SignUpView(showSignInView: .constant(false))
}


extension SignUpView {
    private var signUpView: some View {
        VStack(alignment: .leading, spacing: 5) {
            titleSection
            welcomeSection
            textFieldSection
            forgotPasswordSection
            emailSignInSection
            signInSection
            
            Spacer()
        }
    }
    
    private var titleSection: some View {
        HStack {
            Image(.carlogo)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
            Text("ViaAuto")
                .font(.title2)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding([.horizontal, .top])
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 13) {
            Text("Welcome back!")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            Text("Sign up to find your dream car.")
                .font(.callout)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 8)
    }
    
    private var textFieldSection: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $viewModel.emailText)
                .padding()
                .background()
                .clipShape(.rect(cornerRadius: 15))
            
            ZStack {
                if passwordHidden {
                    SecureField("Password", text: $viewModel.passwordText)
                        .padding()
                        .background()
                        .clipShape(.rect(cornerRadius: 15))
                } else {
                    TextField("Password", text: $viewModel.passwordText)
                        .padding()
                        .background()
                        .clipShape(.rect(cornerRadius: 15))
                }
            }
            .overlay(
                    Button {
                        withAnimation(.none) {
                            passwordHidden.toggle()
                        }
                    } label: {
                        Image(systemName: passwordHidden ? "eye.slash.fill" : "eye.fill")
                                .padding(.trailing)
                    }
                    .buttonStyle(.plain)
                    , alignment: .trailing
                )
        }
        .padding()
    }
    
    private var forgotPasswordSection: some View {
        HStack {
            Spacer()
            
            Button {
                
            } label: {
                Text("Forgot password?")
                    .font(.headline)
            }
            .padding(.trailing)
        }
    }
    
    private var emailSignInSection: some View {
        VStack(spacing: 15) {
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.callout)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(.capsule)
                    .padding()
            }
        }
    }
    
    private var signInSection: some View {
        HStack {
            Spacer()
            Text("Do you have an account?")
                .foregroundStyle(.gray)
            Button {
                signInView.toggle()
            } label: {
                Text("Sign In")
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
    }
}
