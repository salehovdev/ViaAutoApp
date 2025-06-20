//
//  FilterView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import SwiftUI

struct FilterView: View {
    let brands = Bundle.main.decodeBrand("carmodels.json")
    let cities = Bundle.main.decodeCity("italiancities.json")
    
    @StateObject private var viewModel = HomeViewModel()
    

    let fuelType = [
            "Petrol",
            "Diesel",
            "Hybrid",
            "Electric",
            "LPG",
            "CNG",
            "Plug-in Hybrid",
            "Mild Hybrid",
            "Hydrogen",
            "Flex Fuel"
    ]
    
    @State private var selectedBrand: String?
    @State private var selectedModel: String?
    @State private var showBrandModelPicker = false
    @State private var showFilterResults = false
    
    @State private var leftPriceText: String = ""
    @State private var rightPriceText: String = ""
    @State private var leftMileText: String = ""
    @State private var rightMileText: String = ""
    @State private var leftYearText: String = ""
    @State private var rightYearText: String = ""
    @State private var citySelection: CityModel? = nil
    @State private var fuelSelection: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                brandsFilter
                
                priceCitySection
                
                mileageFuelSection
                
                yearSection
            }
            .hideKeyboardOnTap()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        leftPriceText = ""
                        rightPriceText = ""
                        leftMileText = ""
                        rightMileText = ""
                        leftYearText = ""
                        rightYearText = ""
                        citySelection = nil
                        fuelSelection = ""
                    } label: {
                        Text("Reset")
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try? await viewModel.getAllPosts()
                            showFilterResults = true
                        }
                    } label: {
                        Text("Show")
                            .foregroundStyle(.red)
                    }
                    .fullScreenCover(isPresented: $showFilterResults) {
                        
                        let brandModel = selectedModel == nil || selectedModel == "All" ? (selectedBrand ?? "") : "\(selectedBrand ?? "") \(selectedModel!)"
                        
                        let city = citySelection?.city ?? ""
                        let fuel = fuelSelection
                        let minPrice = Int(leftPriceText)
                        let maxPrice = Int(rightPriceText)
                        let minMileage = Int(leftMileText)
                        let maxMileage = Int(rightMileText)
                        let minYear = Int(leftYearText)
                        let maxYear = Int(rightYearText)
                    
                        FilteredPostView(
                            selectedCity: city,
                            selectedBrandModel: brandModel,
                            fuelSelection: fuel,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            minMileage: minMileage,
                            maxMileage: maxMileage,
                            minYear: minYear,
                            maxYear: maxYear
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView()
}

extension FilterView {
    private var brandsFilter: some View {
        VStack {
            HStack {
                Text("Brands and Models")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            GridStack(rows: 3, colomns: 4) { row, col in
                let index = row * 4 + col
                if index < brands.count {
                    let brand = brands[index]
                    
                    BrandLogoView(image: brand.brand)
                        .background(
                            Circle()
                                .stroke(
                                    selectedBrand == brand.brand ? Color.green : .clear, lineWidth: 2
                                )
                        )
                } else {
                    Spacer()
                }
            }
            .padding(.top, 7)
            
            if let brand = selectedBrand, let model = selectedModel {
                HStack {
                    if model == "All" {
                        Text("Selected: \(brand)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    } else {
                        Text("Selected: \(brand) \(model)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        selectedBrand = nil
                        selectedModel = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding(.top, 8)
            }
            
            Button {
                showBrandModelPicker = true
            } label: {
                Text("Show all")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .clipShape(.capsule)
            }
            .padding(.top)
            .sheet(isPresented: $showBrandModelPicker) {
                BrandModelList(
                    selectedBrand: $selectedBrand,
                    selectedModel: $selectedModel,
                    isPresented: $showBrandModelPicker
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var priceCitySection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Price")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 10) {
                TextField("min", text: $leftPriceText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
                TextField("max", text: $rightPriceText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
            }
            .padding([.horizontal, .bottom])
            
            Picker("City", selection: $citySelection) {
                ForEach(cities, id: \.self) { city in
                    Text(city.city)
                        .tag(city as CityModel?)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.navigationLink)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var mileageFuelSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Mileage")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 10) {
                TextField("min", text: $leftMileText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
                TextField("max", text: $rightMileText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
            }
            .padding([.horizontal, .bottom])
            
            Picker("Fuel type", selection: $fuelSelection) {
                ForEach(fuelType, id: \.self) { type in
                    Text(type)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.navigationLink)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var yearSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Year")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 10) {
                TextField("min", text: $leftYearText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
                TextField("max", text: $rightYearText)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 20))
                    .keyboardType(.decimalPad)
            }
            .padding([.horizontal, .bottom])
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
}
