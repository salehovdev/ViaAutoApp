//
//  DatabaseUser.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 03.07.25.
//

import Foundation

struct DatabaseUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let userName: String?
    let photoUrl: String?
    let dateCreated: Date?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        
        if auth.isAnonymous {
            self.userName = "user\(Int.random(in: 1000...9999))"
        } else if let email = auth.email {
            let rawName = email.components(separatedBy: "@").first ?? "user"
            let cleanedName = rawName.components(separatedBy: CharacterSet.decimalDigits).first ?? rawName
            self.userName = cleanedName.capitalized
        } else {
            self.userName = auth.userName
        }
    }
    
    init(userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        userName: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.userName = userName
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case userName = "username"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.userName, forKey: .userName)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
