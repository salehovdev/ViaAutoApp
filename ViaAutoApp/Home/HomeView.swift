//
//  HomeView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI

struct HomeView: View {
    let brands = Bundle.main.decodeBrand("carmodels.json")
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var favoriteVM = FavoritesViewModel()
    
    let colomns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    @State private var url: URL? = nil
    @State private var postUrl: URL? = nil
    @State private var favoriteToggle: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    topBrandsView
                    
                    Spacer()
                }
                .navigationTitle("Home")
                
                carListSection
            }
            .task {
                try? await viewModel.getAllPosts()
                favoriteVM.getFavoritePosts()
            }
        }
    }
}

#Preview {
    HomeView()
}

extension HomeView {
    private var topBrandsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Top Brands")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.leading, .top])
                
                Spacer()
                
                NavigationLink {
                    FilterView()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title)
                }
                .padding([.trailing, .top])
            }
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(brands, id: \.self) { brand in
                        VStack(spacing: 5) {
                            BrandLogoView(image: brand.brand)
                                .padding(4)
                            Text(brand.brand)
                                .font(.headline)
                        }
                        .padding(.bottom, 7)
                    }
                }
                .frame(height: 120)
                .padding(.leading)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
        .padding([.horizontal, .bottom])
    }
    
    private var carListSection: some View {
        VStack {
            HStack {
                Text("Cars")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()
                Spacer()
            }
            
            LazyVGrid(columns: colomns) {
                ForEach(viewModel.posts) { post in
                    NavigationLink {
                        CarDetailView(post: post)
                    } label: {
                        PostCardView(post: post, favoriteVM: favoriteVM)
                    }
                }
                
            }
        }
    }
}

struct PostCardView: View {
    let post: CarPostModel
    @ObservedObject var favoriteVM: FavoritesViewModel
    @State private var url: URL? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let imageUrl = url {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            if favoriteVM.favoritePostIds.contains(post.id) {
                                favoriteVM.deleteFavorites(postId: post.id)
                            } else {
                                favoriteVM.addUserFavoritePost(postId: post.id)
                            }
                        }
                        
                    } label: {
                        Image(systemName: favoriteVM.favoritePostIds.contains(post.id) ? "heart.fill" : "heart")
                            .foregroundStyle(favoriteVM.favoritePostIds.contains(post.id) ? .red : .white)
                            .font(.title2)
                            .padding()
                    }
                }
            } else {
                ProgressView()
                    .frame(height: 200)
            }

            VStack(alignment: .leading) {
                Text("\(post.price) €")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(post.brandModel)")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("\(post.year)" + ", " + "\(post.motor) L" + ", " + "\(post.mileage) km")
                    .font(.callout)

                let date = formattedPostDate(from: post.date)
                Text("\(post.city), \(date)")
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(.ultraThinMaterial)
        }
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.3))
        }
        .task {
            if let path = post.images?.first {
                url = try? await StorageManager.shared.getUrlForImage(path: path)
            }
        }
    }

    func formattedPostDate(from date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "d MMMM"
        fullFormatter.locale = Locale(identifier: "en_US")
        let time = formatter.string(from: date)

        if calendar.isDateInToday(date) {
            return "today \(time)"
        } else if calendar.isDateInYesterday(date) {
            return "yesterday \(time)"
        } else {
            let datePart = fullFormatter.string(from: date)
            return "\(datePart) \(time)"
        }
    }
}
