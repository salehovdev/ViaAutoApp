//
//  CarDetailView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 22.06.25.
//

import SwiftUI

struct CarDetailView: View {
    
    let post: CarPostModel
    
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var imageUrls: [URL] = []
    @State private var isImageViewerPresented = false
    @State private var selectedImageIndex = 0
    
    @State private var isFavorite: Bool = false
    
    @State private var postOwner: DatabaseUser? = nil
    @State private var postOwnerImageURL: URL? = nil
    
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                imageSection
                
                titleSection
                
                Divider()
                
                carDetails
                
                Divider()
                
                
                if let notes = post.notes {
                    Text("\(notes)")
                        .font(.headline)
                        .padding()
                }
                   
                
                Divider()
                
                profileSection
                
                Divider()
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading, content: {
            backButton
        })
        .overlay(alignment: .topTrailing, content: {
            favoriteButton
        })
        .navigationBarBackButtonHidden(true)
        .task {
            try? await viewModel.getAllPosts()
            
            await loadPostImages()
            await loadPostOwner()
            await loadFavoriteStatus()
        }
        .sheet(isPresented: $isImageViewerPresented) {
            FullScreenImageViewer(imageUrls: imageUrls, selectedIndex: $selectedImageIndex)
        }
    }
    
    //MARK: - Task functions
    private func loadPostImages() async {
        guard let imagePaths = post.images else { return }
        
        var urls: [URL] = []
        for path in imagePaths {
            if let url = try? await StorageManager.shared.getUrlForImage(path: path) {
                urls.append(url)
            }
        }
        
        self.imageUrls = urls
    }

    private func loadPostOwner() async {
        do {
            let user = try await UserManager.shared.getNewUser(userId: post.userId)
            self.postOwner = user
            
            if let path = user.photoUrl {
                if path.starts(with: "http") {
                    self.postOwnerImageURL = URL(string: path)
                } else {
                    let imageUrl = try await StorageManager.shared.getUrlForImage(path: path)
                    self.postOwnerImageURL = imageUrl
                }
            }
        } catch {
            print("Failed to load post owner:", error.localizedDescription)
        }
    }

    private func loadFavoriteStatus() async {
        do {
            let user = try AuthenticationManager.shared.getUser()
            let favorites = try await UserManager.shared.getAllFavoritePosts(userId: user.uid)
            self.isFavorite = favorites.contains(where: { $0.postId == post.id })
        } catch {
            print("Failed to load favorite status: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CarDetailView(post: CarPostModel(userId: "", brandModel: "Audi A6", price: "45000", mileage: "55000", motor: "2.5", city: "Florence", fuel: "Petrol", color: "Gray", year: 2020, images: ["car1", "car2"], notes: "Audi A6"))
}

//MARK: - UI part
extension CarDetailView {
    private var imageSection: some View {
        ZStack {
            if imageUrls.isEmpty {
                ProgressView()
                    .frame(height: 300)
            } else {
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(height: 300)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 300)
                .onTapGesture {
                    isImageViewerPresented = true
                }
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(post.brandModel)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title3)
                    }
                }
                
                Text("\(post.price) €")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(post.year)" + ", " + "\(post.motor) L" + ", " + "\(post.mileage) km")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var carDetails: some View {
        VStack(spacing: 0) {
            CarDetails(detail: "City", detailName: "\(post.city)")
            CarDetails(detail: "Year", detailName: "\(post.year)")
            CarDetails(detail: "Color", detailName: "\(post.color)")
            CarDetails(detail: "Fuel", detailName: "\(post.fuel)")
            CarDetails(detail: "Motor", detailName: "\(post.motor) L")
            CarDetails(detail: "Mileage", detailName: "\(post.mileage) km")
        }
        .padding(.bottom)
    }
    
    private var profileSection: some View {
        HStack {
            VStack {
                if let user = postOwner {
                    Text("\(user.userName ?? "")")
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            if let url = postOwnerImageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.gray.opacity(0.5))
                        .clipShape(.circle)
                        .overlay {
                            Circle()
                                .stroke(.gray.opacity(0.5))
                        }
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray.opacity(0.5))
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .stroke(.gray.opacity(0.5))
                    }
            }
        }
        .padding()
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .font(.headline)
                .padding(16)
                .background(.ultraThickMaterial)
                .clipShape(.circle)
                .shadow(radius: 4)
                .padding(.leading, 5)
        }
    }
    
    private var favoriteButton: some View {
        Button {
            Task {
                let user = try AuthenticationManager.shared.getUser()
                isFavorite.toggle()
                
                if isFavorite {
                    try? await UserManager.shared.addUserFavoritePost(userId: user.uid, postId: post.id)
                } else {
                    try? await UserManager.shared.deleteUserFavoritePost(userId: user.uid, postId: post.id)
                }
            }
            
            
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .padding(12)
                .foregroundStyle(isFavorite ? Color.red : .primary)
                .background(.ultraThickMaterial)
                .clipShape(.circle)
                .shadow(radius: 4)
                .padding(.leading, 5)
        }
    }
}

struct CarDetails: View {
    
    let detail: String
    let detailName: String
    
    var body: some View {
        HStack {
            Text(detail)
                .foregroundStyle(.gray)
            Spacer()
            Text(detailName)
        }
        .padding([.horizontal, .top])
    }
}

//MARK: - FullScreen for images
struct FullScreenImageViewer: View {
    let imageUrls: [URL]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedIndex) {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .background(Color.black)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
