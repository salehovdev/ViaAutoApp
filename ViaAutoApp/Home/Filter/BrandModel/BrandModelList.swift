//
//  BrandModelList.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import SwiftUI

struct BrandModelList: View {
    let brands = Bundle.main.decodeBrand("carmodels.json")
    @State private var selectedModels: Set<String> = []
    
    @Binding var selectedBrand: String?
    @Binding var selectedModel: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(brands, id: \.self) { brand in
                    NavigationLink {
                        ModelSelectionView(brand: brand.brand, models: brand.models, selectedModels: $selectedModels, selectedBrand: $selectedBrand, selectedModel: $selectedModel, isPresented: $isPresented)
                    } label: {
                        HStack {
                            Image(brand.brand)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .background(.gray)
                                .clipShape(.circle)
                                .overlay {
                                    Circle()
                                        .stroke(.gray)
                                }
                            
                            Text(brand.brand)
                        }
                    }
                }
            }
            .navigationTitle("Brand and Models")
        }
    }
}

#Preview {
    BrandModelList(selectedBrand: .constant(""), selectedModel: .constant(""), isPresented: .constant(false))
}
