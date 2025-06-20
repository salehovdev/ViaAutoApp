//
//  SignInView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 20.06.25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    
    @StateObject var viewModel = SignInEmailViewModel()
    @StateObject var ssoViewModel = SsoSignInViewModel()
    @Binding var showSignInView: Bool
    
    @State private var passwordHidden: Bool = true
    @State private var signUpView: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            if !signUpView {
                signInView
                    .transition(.move(edge: .leading))
            } else {
                SignUpView(showSignInView: $showSignInView)
                    .transition(.move(edge: .trailing))
            }
        }
        .alert("Sign In Failed!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .animation(.easeInOut(duration: 0.5), value: signUpView)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    SignInView(showSignInView: .constant(false))
}

extension SignInView {
    private var signInView: some View {
        VStack(alignment: .leading, spacing: 5) {
            titleSection
            welcomeSection
            textFieldSection
            forgotPasswordSection
            emailSignInSection
            ssoSection
            signUpSection
            
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
            
            Text("Sign in to find your dream car.")
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
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        await MainActor.run {
                            alertMessage = "Email or password is incorrect"
                            showAlert = true
                        }
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.callout)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(.capsule)
                    .padding()
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 1)
                    .padding()
                Text("or")
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 1)
                    .padding()
            }
            .foregroundStyle(.gray)
        }
    }
    
    private var ssoSection: some View {
        HStack {
            Spacer()
            
            Button {
                Task {
                    do {
                        try await ssoViewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Image(.google)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial, in: Circle())
            
            Button {
                Task {
                    do {
                        try await ssoViewModel.signInApple()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .padding()
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial, in: Circle())
            
            Button {
                Task {
                    do {
                        try await ssoViewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial, in: Circle())
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var signUpSection: some View {
        HStack {
            Spacer()
            Text("Don't have an account?")
                .foregroundStyle(.gray)
            Button {
                signUpView.toggle()
            } label: {
                Text("Sign Up")
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
    }
}
