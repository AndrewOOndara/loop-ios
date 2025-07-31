//
//  Models.swift
//  loop
//
//  Created by Andrew Ondara on 7/17/25.
//n

import Foundation

struct Profile: Codable {
    let username: String?
    let fullName: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case avatarURL = "avatar_url"
    }
}

struct Post: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let content: String
    let image_url: String?
    let created_at: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case content
        case image_url
        case created_at
    }
}


