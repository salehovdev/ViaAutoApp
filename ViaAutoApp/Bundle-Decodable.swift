//
//  Bundle-Decodable.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 24.06.25.
//

import Foundation

extension Bundle {
    func decodeBrand(_ file: String) -> [BrandModel] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in the bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedData = try? decoder.decode([BrandModel].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        
        return loadedData
    }
    
    func decodeCity(_ file: String) -> [CityModel] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in the bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedData = try? decoder.decode([CityModel].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        
        return loadedData
    }
}
