//
//  FilteredPostView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 25.06.25.
//

import SwiftUI

struct FilteredPostView: View {
    let selectedCity: String
    let selectedBrandModel: String
    let fuelSelection: String
    let minPrice: Int?
    let maxPrice: Int?
    let minMileage: Int?
    let maxMileage: Int?
    let minYear: Int?
    let maxYear: Int?
    
    let colomns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    @StateObject var viewModel = HomeViewModel()
    @StateObject var favoriteVM = FavoritesViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colomns) {
                    ForEach(viewModel.posts.filter {
                        (selectedCity.isEmpty || $0.city == selectedCity) &&
                        (selectedBrandModel.isEmpty || $0.brandModel.contains(selectedBrandModel)) &&
                        (fuelSelection.isEmpty || $0.fuel == fuelSelection) &&
                        (minPrice == nil || (Int($0.price) ?? 0) >= minPrice!) &&
                        (maxPrice == nil || (Int($0.price) ?? 0) <= maxPrice!) &&
                        (minMileage == nil || (Int($0.mileage) ?? 0) >= minMileage!) &&
                        (maxMileage == nil || (Int($0.mileage) ?? 0) <= maxMileage!) &&
                        (minYear == nil || $0.year >= minYear!) &&
                        (maxYear == nil || $0.year <= maxYear!) }) { post in
                        NavigationLink {
                            CarDetailView(post: post)
                        } label: {
                           PostCardView(post: post, favoriteVM: favoriteVM)
                        }
                    }
                }
            }
            .navigationTitle("Results")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Text("Back to")
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
        }
        .task {
            try? await viewModel.getAllPosts()
            favoriteVM.getFavoritePosts()
        }
    }
}

#Preview {
    FilteredPostView(selectedCity: "Rome", selectedBrandModel: "BMW X6", fuelSelection: "Petrol", minPrice: 0, maxPrice: 0, minMileage: 0, maxMileage: 0, minYear: 0, maxYear: 0)
}
