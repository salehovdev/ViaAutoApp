//
//  ProfileView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var selectedImage: PhotosPickerItem?
    
    @State private var showLogOutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @State private var showPasswordSheet: Bool = false
    @State private var newPassword = ""
    
    @State private var showEmailSheet: Bool = false
    @State private var newEmail = ""
    
    @State private var showLinkEmailSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if viewModel.providers.contains(.google) {
                            if let urlString = viewModel.user?.photoUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle().stroke(.gray)
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        } else if viewModel.providers.contains(.email) {
                            if let url = viewModel.url {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                            }
                        }
                    }
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.gray)
                    }
                    
                    if viewModel.providers.contains(.email) {
                        PhotosPicker(selection: $selectedImage) {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.white)
                                .frame(width: 5, height: 5)
                                .padding(15)
                                .background(.red)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(.white)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onChange(of: selectedImage) { oldValue, newValue in
                    if let newValue {
                        viewModel.saveProfileImage(item: newValue)
                    }
                }
                  
                if let user = viewModel.user {
                    Text("\(user.userName ?? "")")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                if let user = viewModel.user {
                    Text("\(user.email ?? "")")
                }
                
                List {
                    if viewModel.providers.contains(.email) {
                        Button {
                            showEmailSheet = true
                        } label: {
                            HStack {
                                Label("Change email", systemImage: "envelope")
                                Spacer()
                                Image(systemName: "pencil")
                            }
                        }
                        .sheet(isPresented: $showEmailSheet) {
                            emailSheetView
                        }
                        
                        Button {
                            showPasswordSheet = true
                        } label: {
                            HStack {
                                Label("Change password", systemImage: "person.badge.key")
                                Spacer()
                                Image(systemName: "pencil")
                            }
                        }
                        .sheet(isPresented: $showPasswordSheet) {
                            passwordSheetView
                        }
                    }
                    
                    if viewModel.user?.isAnonymous == true {
                        Button {
                            showLinkEmailSheet = true
                        } label: {
                            HStack {
                                Label("Link to Email", systemImage: "envelope.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .sheet(isPresented: $showLinkEmailSheet) {
                            linkEmailSheetView
                        }
                        
                        
                        Button {
                            Task {
                                do {
                                    try await viewModel.linkGoogle()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            HStack {
                                Label("Link to Google", systemImage: "g.circle.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await viewModel.linkApple()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            HStack {
                                Label("Link to Apple", systemImage: "apple.logo")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete account", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                    .alert("Delete Account", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.deleteAccount()
                                    showSignInView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure to delete account?")
                    }

                    
                    Button {
                        showLogOutAlert = true
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                    }
                    .alert("Log out", isPresented: $showLogOutAlert) {
                        Button("Log Out", role: .destructive) {
                            Task {
                                do {
                                    try viewModel.logOut()
                                    showSignInView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure to log out?")
                    }
                    
                }
                .listStyle(.plain)
                
                Spacer()
                
            }
            .task {
                try? await viewModel.loadUser()
                
                if let path = viewModel.user?.photoUrl {
                    let url = try? await StorageManager.shared.getUrlForImage(path: path)
                    viewModel.url = url
                }
            }
            .onAppear {
                viewModel.loadProviders()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Profile")
        }
    }
    
    private var passwordSheetView: some View {
        VStack(spacing: 20) {
            Text("Enter new password")
                .font(.headline)
            
            TextField("New password", text: $newPassword)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            
            Button("Save") {
                Task {
                    try await viewModel.changePassword(password: newPassword)
                    showPasswordSheet = false
                    newPassword = ""
                }
            }
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            
            Button("Cancel", role: .cancel) {
                showPasswordSheet = false
            }
        }
        .padding()
    }
    
    private var emailSheetView: some View {
        VStack(spacing: 20) {
            Text("Enter new email")
                .font(.headline)
            
            TextField("New email", text: $newEmail)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            
            Button("Save") {
                Task {
                    try await viewModel.changeEmail(email: newEmail)
                    showEmailSheet = false
                    newEmail = ""
                }
            }
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            
            Button("Cancel", role: .cancel) {
                showEmailSheet = false
            }
        }
        .padding()
    }
    
    private var linkEmailSheetView: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $newEmail)

                TextField("Password", text: $newPassword)


                Button("Link Email") {
                    Task {
                        do {
                            try await viewModel.linkEmail(email: newEmail, password: newPassword)
                            showLinkEmailSheet = false
                            newEmail = ""
                            newPassword = ""
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .navigationTitle("Link Email")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showLinkEmailSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))
}
