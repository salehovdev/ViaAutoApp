//
//  CarPostModel.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 06.07.25.
//

import Foundation

struct CarPostModel: Codable, Identifiable {
    var id = UUID().uuidString
    let userId: String
    let brandModel: String
    let price: String
    let mileage: String
    let motor: String
    let city: String
    let fuel: String
    let color: String
    let year: Int
    let images: [String]?
    let notes: String?
    var date = Date()
    
    static func ==(lhs: CarPostModel, rhs: CarPostModel) -> Bool {
        return lhs.id == rhs.id
    }
}
