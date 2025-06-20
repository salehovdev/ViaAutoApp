//
//  BrandLogoView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI

struct BrandLogoView: View {
    
    let image: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()
                .background(.gray.opacity(0.2))
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                }
        }
    }
}

#Preview {
    BrandLogoView(image: "bmw")
}
