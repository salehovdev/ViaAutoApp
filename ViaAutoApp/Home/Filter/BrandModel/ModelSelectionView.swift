//
//  ModelSelectionView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import SwiftUI

struct ModelSelectionView: View {
    let brand: String
    let models: [String]
    
    @Binding var selectedModels: Set<String>
    @Binding var selectedBrand: String?
    @Binding var selectedModel: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        List(models, id: \.self) { model in
            HStack {
                Text(model)
                Spacer()
            }
            .contentShape(.rect)
            .onTapGesture {
                selectedBrand = brand
                selectedModel = model
                isPresented = false
            }
        }
    }
}

#Preview {
    FilterView()
}
