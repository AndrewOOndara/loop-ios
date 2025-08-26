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

struct UserGroup: Codable, Identifiable, Hashable {
    let id: Int // Changed from UUID to Int to match your database
    let name: String
    let groupCode: String
    let avatarURL: String?
    let createdBy: UUID
    let createdAt: Date?
    let updatedAt: Date?
    let isActive: Bool
    let maxMembers: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case groupCode = "group_code"
        case avatarURL = "avatar_url"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isActive = "is_active"
        case maxMembers = "max_members"
    }
}

struct GroupMember: Codable, Identifiable, Hashable {
    let id: Int // Changed from UUID to Int to match your database  
    let groupId: Int // Changed from UUID to Int
    let userId: UUID
    let role: String
    let joinedAt: Date?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case userId = "user_id"
        case role
        case joinedAt = "joined_at"
        case isActive = "is_active"
    }
}

// Helper struct for joining groups
struct GroupJoinRequest {
    let groupCode: String
    let userId: UUID
}


