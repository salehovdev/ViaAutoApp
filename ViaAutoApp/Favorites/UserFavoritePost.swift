//
//  UserFavoritePost.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 08.07.25.
//

import Foundation

struct UserFavoritePost: Codable, Identifiable {
    let id: String
    let postId: String
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postId = "post_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.postId, forKey: .postId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
}
