//
//  Models.swift
//  loop
//
//  Created by Andrew Ondara on 7/17/25.
//n

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let phoneNumber: String
    let firstName: String?
    let lastName: String?
    let username: String?
    let profileBio: String?
    let avatarURL: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case profileBio = "profile_bio"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
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


