//
//  BrandModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import Foundation

struct BrandModel: Codable, Hashable {
    let brand: String
    let models: [String]
}
