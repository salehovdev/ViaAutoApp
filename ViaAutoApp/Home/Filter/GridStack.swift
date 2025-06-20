//
//  GridStack.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import SwiftUI

struct GridStack<Content: View>: View {
    let rows: Int
    let colomns: Int
    @ViewBuilder let content: (Int, Int) -> Content
    
    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<colomns, id: \.self) { colomn in
                        content(row, colomn)
                    }
                }
            }
        }
    }
}


#Preview {
    FilterView()
}
