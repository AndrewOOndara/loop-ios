//
//  Models.swift
//  loop
//
//  Created by Andrew Ondara on 7/17/25.
//n

import Foundation

struct Profile: Codable, Identifiable, Hashable {
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
        case avatarURL = "profile_pic"
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

// MARK: - Group Member with Profile
struct GroupMemberWithProfile: Codable, Identifiable, Hashable {
    let id: Int
    let groupId: Int
    let userId: UUID
    let role: String
    let joinedAt: Date?
    let isActive: Bool
    let profiles: Profile
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case userId = "user_id"
        case role
        case joinedAt = "joined_at"
        case isActive = "is_active"
        case profiles
    }
}

// Helper struct for joining groups
struct GroupJoinRequest {
    let groupCode: String
    let userId: UUID
}

// MARK: - Group Media

enum GroupMediaType: String, Codable {
    case image
    case video
    case audio
    case music
}

struct GroupMedia: Codable, Identifiable, Hashable {
    let id: Int
    let groupId: Int
    let userId: UUID
    let storagePath: String
    let mediaType: GroupMediaType
    let thumbnailPath: String?
    let caption: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case userId = "user_id"
        case storagePath = "storage_path"
        case mediaType = "media_type"
        case thumbnailPath = "thumbnail_path"
        case caption
        case createdAt = "created_at"
    }
}


